# Documenty
Documenty constists of two things:
1. A format specification for describing a RESTful API
2. An executable (by installing it as a gem) for turning said YAML file into an HTML file to view in the browser.

## Example .yml file
```yml
---
Base:
  Name: Pushly REST JSON API
  Version: 1
  Path Prefix: http://push.ly/api/business/v1
  

Resources: Customer, Package

Descriptions:
  Customer:
    what: Add, delete and inspect your business' customers.
    actions:
      index:
        path: "/customers"
        what: Returns a list of your business' customers
      show:
        path: "/customers/:id"
        what: Returns information about a particular customer
      create:
        path: "/customers"
        what: Create a new customer associated with your business
  Package:
    what: Add, delete and inspec your business' packages.
    actions:
      index:
        path: "/customers"
        what: Returns a list of your business' customers
      custom_action:
        method: "GET"
        path: "/customers/:id/custom_action"
        what: Does <something> to a customer
```
Documenty demands a few things:

1. A name, a version and a path prefix. The path prefix is prefixed to every path specified
2. A list of resources
3. Each resource needs a description and documenty will spew out errors if something is missing

Normal RESTful actions (index/show/create/update/destroy) do not need a method specified, Documenty assumes that they
are accessed through get/get/post/put/delete respectively. Said default methods can be overwritten by simply specifying
a method.


## Command line usage
To generate an HTML file with descriptions of your API simply specify the input .yml file and optionally a directory to
which Documenty should write the files. The output directory defaults to ./documenty_doc/.

```
Usage:
  documenty input_file [output_directory]

Options:
  input_file: The .yml file to be parsed
  output_file: The directory that documenty should put its output in.
                    default output directory: ./documenty_doc/index.html
```