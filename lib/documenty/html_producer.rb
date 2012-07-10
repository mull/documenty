require 'nokogiri'
module Documenty
  class HTMLProducer
    def self.produce(attributes, output_directory)
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.head {
            doc.link(
              :rel => "stylesheet",
              :href => "style.css",
              :type => "text/css"
            )

            doc.title {
              doc.text attributes[:base]["name"]
            }
          }
          doc.body {
            doc.header {
              doc.h1 {
                doc.text attributes[:base]["name"]
              }
            }

            doc.div(:id => 'content') {
              attributes[:resources].each do |resource, description|

                doc.div(:class => 'resource', :id => "resource-#{resource}") {
                  doc.h2 {
                    doc.text resource
                  }

                  doc.p {
                    doc.text description["description"]
                  }

                  doc.table.actions {
                    doc.thead {
                      doc.th {
                        doc.text "Resource"
                      }

                      doc.th {
                        doc.text "Description"
                      }
                    }

                    doc.tbody {
                      description["actions"].each do |action, keys|
                        doc.tr.resource_action {
                          doc.td(:class => "action-path") {
                            doc.text keys["method"]
                            doc.text " "
                            doc.text keys["path"]
                          }

                          doc.td(:class => "action-what") {
                            doc.text keys["description"]
                          }
                        }
                      end
                    }
                  }
                }
              end
            }
          }
        }
      end

      File.open(output_directory, "w+") do |f|
        f << builder.to_html
      end
    end
  end
end