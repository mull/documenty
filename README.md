# Documenty
Documenty constists of two things:
1. A format specification for describing a RESTful API
2. An executable (by installing it as a gem) for turning said YAML file into an HTML file to view in the browser.

## Example .yml file
```yml
---
base:
  name: Pushly REST JSON API
  version: 1
  url: http://push.ly/api/business/v1
  
resources:
  customers:
    description: Add, delete and inspect your business' customers.
    actions:
      index:
        path: /customers
        description: Returns a list of your business' customers
      show:
        path: /customers/:id
        description: Returns information about a particular customer
        parameters:
          id: The id of the customer
      create:
        path: /customers
        description: Create a new customer associated with your business
  packages:
    description: Add, delete and inspec your business' packages.
    actions:
      index:
        path: /customers
        description: Returns a list of your business' customers
      custom_action:
        method: GET
        path: /customers/:id/custom_action
        description: Does <something> to a customer
        parameters:
          id: The id of the customer
```
Documenty demands a few things:

1. A name, a version and a path prefix. The path prefix is prefixed to every path specified
2. Each resource needs a description and documenty will spew out errors if something is missing

Normal RESTful actions (index/show/create/update/destroy) do not need a method specified, Documenty assumes that they
are accessed through get/get/post/put/delete respectively. Said default methods can be overwritten by simply specifying
a method.


## Command line usage
To generate an HTML file with descriptions of your API simply specify the input .yml file and optionally a directory to
which Documenty should write the files. The output directory defaults to ./documenty_doc/.

```
Documenty Yaml API Parser 0.1

Usage:
  documenty input_file [output_directory]

Options:
  input_file: The .yml file to be parsed
  output_file: The directory that documenty should put its output in.
                    default output directory: ./apidoc/index.html
```

# TODO
1. Response codes and response objects (feel free to suggest a nice way to do this by opening an issue)
2. Nested resources

# Contributing
Bug reports, pull requests and general feedback are always welcome!