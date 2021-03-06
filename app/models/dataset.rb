require 'rexml/document'

include REXML
class Dataset < ActiveRecord::Base  
  has_many :datatables, :order => 'name'
  has_many :protocols, :conditions => 'active is true'
  has_many :people, :through => :affiliations
  has_many :affiliations, :order => 'seniority'
  has_many :roles, :through => :affiliations, :uniq => true
  has_and_belongs_to_many :themes
  belongs_to :project
  has_and_belongs_to_many :studies
  belongs_to :sponsor
  belongs_to :website
  
  validates_presence_of :abstract

  accepts_nested_attributes_for :affiliations, :allow_destroy => true
  
  acts_as_taggable_on :keywords
    
  def has_person(id)
    person = Person.find(id)
    people.exists?(person)
  end
  
  def datatable_people
    datatables.collect do |table|
      table.people
    end.flatten
  end
   
  def within_interval?(start_date=Date.today, end_date=Date.today)   
    sdate = start_date.to_date
    edate = end_date.to_date
    any_within_interval = datatables.collect do |datatable|
      datatable.within_interval?(sdate, edate)
    end
    #TODO query the start and end dates as well
    any_within_interval.include?(true)
  end
  
  def principal_contact
  end
    
  #unpack and populate datatables and variates  
  def from_eml(dataset)
    dataset.elements.each do |element|
      self.send(element.name, element.value)
    end
    dataset.elements['//dataTable'].each do |datatable|
      dtable = DataTable.new
      dtable.from_eml(datatable)
      datatables << dtable
    end
  end  
  
  def to_eml
    emldoc = Document.new(%q{<?xml version="1.0" encoding="UTF-8"?>
<eml:eml xmlns:eml="eml://ecoinformatics.org/eml-2.0.0" xmlns:set="http://exslt.org/sets" xmlns:exslt="http://exslt.org/common" xmlns:stmml="http://www.xml-cml.org/schema/stmml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="eml://ecoinformatics.org/eml-2.0.0 eml.xsd" packageId="knb-lter-kbs.1.8" system="KBS LTER">
</eml:eml>})
    eml_dataset = emldoc.root.add_element('dataset')
    eml_dataset.add_element('title').add_text(title)
    creator = eml_dataset.add_element('creator', {'id' => 'KBS LTER'})
    creator.add_element('positionName').add_text('Data Manager')
    
    [people, datatable_people].flatten.uniq.each do |person|
        p = eml_dataset.add_element('associatedParty', {'id' => person.person, 'scope' => 'document'})      
        p.add_element eml_individual_name(person)
        p.add_element address(person)
        p.add_element('phone', {'phonetype' => 'phone'}).add_text(person.phone) if person.phone
        p.add_element('phone',{'phonetype' => 'fax'}).add_text(person.fax) if person.fax
        p.add_element('electronicMailAddress').add_text(person.email) if person.email
        #      p.add_element('role').add_text(person)
      end
    
    eml_dataset.add_element('abstract').add_element('para').add_text(textilize(abstract))
    eml_dataset.add_element keyword_sets
    eml_dataset.add_element contact_info
    eml_dataset.add_element eml_access

    unless initiated.nil? or completed.nil?
      coverage = eml_dataset.add_element('coverage')
      temporal_coverage = coverage.add_element('temporalCoverage')
      range_of_dates = temporal_coverage.add_element('rangeOfDates')
      begin_calendar_date = range_of_dates.add_element('beginDate').add_element('calendarDate')
      end_calendar_date = range_of_dates.add_element('endDate').add_element('calendarDate')
      begin_calendar_date.add_text(initiated.to_s)
      end_calendar_date.add_text(completed.to_s)
    end

    datatables.each do |datatable|
      eml_dataset.add_element datatable.to_eml
    end
    eml_dataset.add_element('additionalMetadata').add eml_custom_unit_list
    emldoc.root.to_s
  end
  
 
  #temporal extent
  def temporal_extent
    begin_date = nil
    end_date = nil
    datatables.each do |datatable |
      dates = datatable.temporal_extent
      datatable.update_temporal_extent
      next if dates[:begin_date].nil?
      next if dates[:end_date].nil?
      begin_date = dates[:begin_date] if begin_date.nil? || begin_date > dates[:begin_date]
      end_date = dates[:end_date] if end_date.nil? || end_date < dates[:end_date]
    end
    {:begin_date => begin_date, :end_date => end_date}
  end
  
   def update_temporal_extent
     dates = temporal_extent
     self.initiated = dates[:begin_date] if dates[:begin_date]
     self.completed = dates[:end_date] if dates[:end_date]
     save
   end
  
private

  def eml_custom_unit_list
    custom_units = self.datatables.collect do | datatable |
      datatable.variates.collect do | variate |
        next unless variate.unit
        next unless !variate.unit.in_eml
        variate.unit.definition
      end
    end
    
    e = Element.new('stmml:unitList')
    e.add_attribute('xsi:schemaLocation',"http://www.xml-cml.org/schema/stmml http://lter.kbs.msu.edu/Data/schemas/stmml.xsd")
    
    custom_units.flatten.compact.sort.uniq.each do |unit|
      e.add_text unit
    end
    return e
  end

  def eml_individual_name(person)
    i = Element.new('individualName')
    i.add_element('givenName').add_text( person.given_name )
    i.add_element('surName').add_text( person.sur_name )
    return i
  end
  
  def eml_access
    a = Element.new('access')
    a.add_attribute('scope','document')
    a.add_attribute('order','allowFirst')
    a.add_attribute('authSystem', 'knb')
    a.add_element eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
    a.add_element eml_allow('public','read')
    return a
  end
  
  def eml_allow(principal, permission)
    a = Element.new('allow')
    a.add_element('principal').add_text(principal)
    a.add_element('permission').add_text(permission)  
    return a
  end
  
  def keyword_sets
    k = Element.new('keywordSet')
    ['LTER','KBS','Kellogg Biological Station', 'Hickory Corners', 'Michigan', 'Great Lakes'].each do| keyword |
      k.add_element('keyword', {'keywordType' => 'place'}).add_text(keyword)
    end
    return k
  end
  
  def contact_info
    i = Element.new('contact')
    i.add_element('organizationName').add_text('Kellogg Biological Station')
    i.add_element('positionName').add_text('Data Manager')
    p = Person.new( :organization => 'Kellogg Biological Station',
      :street_address => '3700 East Gull Lake Drive',
      :city => 'Hickory Corners',:locale => 'Mi',:postal_code => '49060',
      :country => 'USA')
    a = i.add_element address(p)
    a.add_element('electronicMailAddress').add_text('data.manager@kbs.msu.edu')
    a.add_element('onlineUrl').add_text('http://lter.kbs.msu.edu')
    return i
  end

  def address(person)
    a = Element.new('address')
    a.add_attribute('scope','document')
    a.add_element('deliveryPoint').add_text(person.organization) if person.organization
    a.add_element('deliveryPoint').add_text(person.street_address) if person.street_address
    a.add_element('city').add_text(person.city) if person.city
   # a.add_element('administrativeArea').add_text(person.locale) if person.locale
    a.add_element('postalCode').add_text(person.postal_code) if person.postal_code
    a.add_element('country').add_text(person.country) if person.country
    return a
  end
end

