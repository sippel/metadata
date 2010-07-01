Factory.define :person do |p|
  p.sur_name 'bauer'
  p.given_name 'bill'
end

Factory.define :role do |r|
  r.name 'Emeritus Investigators'
end

Factory.define :theme do |t|
  t.name  'Agronomic'
end

Factory.define :dataset do |d|
  d.title 'KBS001'
  d.abstract 'some new dataset'
end

Factory.define :protocol do |p|
  p.name  'Proto1'
  p.version  0
  p.dataset Factory.create(:dataset)
end

Factory.define :study do |s|
  s.name 'LTER'
end

Factory.define :variate do |v|
  v.name 'date'
end

Factory.define :datatable do |d|
  d.name          'KBS001_001'
  d.title         'a really cool datatable'
  d.object        'select now() as sample_date'
  d.is_sql         true
  d.description   'This is a datatable'
  d.weight        100
  d.theme         Factory.create(:theme)
end

Factory.define :website do |w|
end

Factory.define :template do |t|
end

Factory.define :publication do |p|
  p.citation            'bogus data, brown and company'
  p.abstract            'something in here'
  p.year                2000
  p.publication_type_id 1
end

Factory.define :sponsor do |s|
  s.name    'LTER'
end