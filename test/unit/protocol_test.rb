require File.dirname(__FILE__) + '/../test_helper'

class ProtocolTest < ActiveSupport::TestCase
  should have_and_belong_to_many :websites
  should have_and_belong_to_many :datatables
  
  context 'a protocol' do
    setup do
      @website = Factory :website, :name=>'lter'
      @website2 = Factory :website, :name => 'glbrc'
      @protocol = Factory.create(:protocol)
    end
    
    should 'save websites' do
      @protocol.website_list = {@website.id.to_s => '1', @website2.id.to_s => '0'}
      assert @protocol.save
      
      assert @protocol.websites.include?(@website)
    end
    
    should 'save multiple websites' do
       @protocol.website_list = {@website.id.to_s => '1', @website2.id.to_s => '1'}
        assert @protocol.save

        assert @protocol.websites.include?(@website)
        assert @protocol.websites.include?(@website2)
    end

  end
end
