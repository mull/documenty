Gem::Specification.new do |s|
  s.name        = 'documenty'
  s.version     = '0.1.0'
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.date        = '2012-07-09'
  s.summary     = "Lightweight documentation for RESTful APIs"
  s.description = "Create documentation for your APIs through an easy to read and maintain YAML format."
  s.authors     = ["Emil Ahlbäck"]
  s.email       = 'e.ahlback@gmail.com'
  s.files       = [
    "lib/documenty.rb",
    "lib/documenty/yaml_parser.rb",
    "lib/documenty/html_producer.rb",
    "lib/documenty/resource_html_producer.rb"
  ]
  s.require_paths = ["lib/documenty", "lib/"]
  s.homepage    =
    'https://github.com/pushly/documenty'

  s.add_runtime_dependency 'nokogiri'
end
