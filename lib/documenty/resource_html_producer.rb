module Documenty
  class ResourceHTMLProducer
    def self.produce(name, resource, output_directory='./')
      puts "#{self.name}: Producing resource #{name}"
      resource["actions"].each do |action, keys|
        escaped_path = Documenty::escaped_action_path(keys['path'], keys['method'])

        builder = Nokogiri::HTML::Builder.new do |doc|
          doc.html {
            self.produce_header(name, resource, output_directory, doc)
            doc.body {
              self.produce_content(action, keys, doc)
            }
          }
        end

        FileUtils::mkdir_p( File.join(output_directory, File.dirname(escaped_path)) )

        File.open( File.join(output_directory, escaped_path), "w+") do |f|
          f << builder.to_html
        end
      end
    end

    def self.produce_header(name, resource, output_directory, doc)
      doc.head {
        doc.title {
          doc.text name
        }

        doc.link(
          :rel => "stylesheet",
          # TODO: Make this path configurable
          :href => '/api/style.css',
          :type => "text/css"
        )
      }
    end

    def self.produce_content(action, keys, doc)
      doc.div(:id => 'content') {
        doc.h2 {
          # Add method
          doc.text keys["path"]
        }

        doc.h3 {
          doc.text "Parameters"
        }

        if keys["parameters"]
          doc.table.parameter_list {
            doc.thead {
              doc.th {
                doc.text "Name"
              }

              doc.th {
                doc.text "Description"
              }
            }

            doc.tbody {
              keys["parameters"].each do |parameter_name, parameter_description|
                doc.tr {
                  doc.td {
                    doc.text parameter_name
                  }
                  doc.td {
                    doc.text parameter_description
                  }
                }
              end
            }
          }
        end
      }

      doc.div.resource(id: 'sidebar') {
        doc.h4 {
          doc.text "Resource information"
        }

        # TODO: Implement this :)
        doc.table.info {
          doc.tbody {
            doc.tr {
              doc.td {
                doc.text "Requires authentication?"
              }

              doc.td {
                doc.text "Yes"
              }
            }

            doc.tr {
              doc.td {
                doc.text "HTTP method"
              }

              doc.td {
                doc.text action["method"]
              }
            }
          }
        }
      }
    end
  end

end