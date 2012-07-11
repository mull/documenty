require 'nokogiri'
require 'fileutils'
require 'uri'
require 'resource_html_producer'

=begin
{  
  :base=>{
    "name"=>"push.ly JSON API", 
    "version"=>"1", 
    "url"=>"http://push.ly"
  }, 
  :resources=>{
    "customer"=>{
      "actions"=>{
        "index"=>{
          "path"=>"/api/business/v1/customers(.:format)", 
          "method"=>"GET", 
          "description"=>"Returns a list of the authenticated business' customers"
        }, 
        "create"=>{
          "path"=>"/api/business/v1/customers(.:format)", 
          "method"=>"POST", 
          "description"=>"Creates a new customer, returns details of said customer on success."
        }, 
        "show"=>{
          "path"=>"/api/business/v1/customers/:id(.:format)", 
          "method"=>"GET", 
          "description"=>"Returns details of the customer", 
          "parameters"=>{
            "id"=>"Customer id"
          }
        }, 
        "update"=>{
          "path"=>"/api/business/v1/customers/:id(.:format)", 
          "method"=>"PUT"
        }, 
        "destroy"=>{
          "path"=>"/api/business/v1/customers/:id(.:format)", 
          "method"=>"DELETE", 
          "description"=>"Deletes a customer", 
          "parameters"=>{
            "id"=>"Customer id"
          }
        }
      }, 
      "description"=>"Perform CRUD operations on a customer"
    }
  }
}

  
=end

module Documenty
  # Turns a Rails path (yes, this is such a rails specific method :/)
  # like /customers/:id/purchases/:id
  # into get/customers/id/purchases/id.html
  # TODO: Figure out a platform neutral ways to do this
  def self.escaped_action_path(path, method='GET')
    new_path = /([\/:\w]+)/.match(path)[0]
    new_path.gsub!(':', '')
    new_path = "#{method}#{new_path}.html"
    #URI.escape(new_path, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).to_s
  end

  # Concatenates n paths, adds a scheme if none is found
  # Lastly it removes any duplicate slashes
  def self.concatenate_paths(*paths)
    return nil if paths.nil? || paths.empty?
    path = paths.join('/')
    uri = URI.parse(path)
    scheme = uri.scheme.nil? ? 'http' : uri.scheme
    path = path.split(/([https|http]+\:\/{2})/).last
    path.gsub!(/\/{2,}/, '/') # Remove any // occurences that might have come along
    "#{scheme}://#{path}"
  end

  # Scans through all the attributes (see structure above from =begin to =end)
  # and produces an HTML page with links to all requests/actions
  # uses HTMLResourceProducer to produce individual HTML files for requests
  class HTMLProducer
    def self.produce(attributes, output_directory)
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          self.produce_head(attributes, doc)

          doc.body {
            self.produce_header(attributes, doc)
            self.produce_content(attributes, doc) 
          }
        }
      end

      # Create the directories necessary to create our output
      # TODO: Handle exceptions
      FileUtils::mkdir_p( output_directory )

      File.open( File.join(output_directory, 'index.html'), "w+") do |f|
        f << builder.to_html
      end

      attributes["resources"].each do |name, resource|
        Documenty::ResourceHTMLProducer.produce(name, resource, output_directory)
      end 
    end

    def self.produce_head(attributes, doc)
      url = attributes["base"]["url"]
      doc.head {
        doc.link(
          :rel => "stylesheet",
          # TODO: Make this path configurable
          #:href => "/api/style.css",
          :href => Documenty::concatenate_paths(url, 'style.css'),
          :type => "text/css"
        )

        doc.title {
          doc.text attributes["base"]["name"]
        }
      }
    end

    def self.produce_header(attributes, doc)
      doc.header {
        doc.h1 {
          doc.text attributes["base"]["name"]
        }
      }
    end

    def self.produce_content(attributes, doc) 
      url = attributes["base"]["url"]
      doc.div(:id => 'content') {
        attributes["resources"].each do |resource, description|

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
                      escaped_path = Documenty::escaped_action_path(keys['path'], keys['method'])
                      escaped_path = Documenty::concatenate_paths(url, escaped_path)
                      doc.a(:href => escaped_path) {
                        doc.text keys["method"]
                        doc.text " "
                        doc.text keys['path']
                      }
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
    end
  end
end