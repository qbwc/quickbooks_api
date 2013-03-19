## About

*quickbooks_api* is a quickbooks xml parser and API inspection tool. It gives
you the ability to easilty go from qbxml to ruby and vice versa. 

### Initialization
------------------------------------------------------------------------------

standard initialization
  
    api = Quickbooks::API.instance(:qbpos)

shorthand initialization

    api = Quickbooks::API[:qbpos]


:qb and :qbpos are the two supported init modes.

### API Introspection
------------------------------------------------------------------------------

return all available wrapper classes

    api.qbxml_classes

return the top level wrapper class for the api

    api.container

find specific qbxml class by name

    api.find('customer_mod_rq')

find all qbxml classes that contain a pattern

    api.grep(/_mod_rq/)

return a hash of all the data types for a wrapper class

    wrapper_class.template

return the full teplate for a wrapper class (SLOOOW for top level classes)

    wrapper_class.template(true)

return all the supported fields for the wrapper class

    wrapper_class.attribute_names

return the qbxml template used to generate the wrapper class

    wrapper_class.xml_template


### QBXML To Ruby
------------------------------------------------------------------------------

wrap qbxml data in a qbxml object

    o = api.qbxml_to_obj(qbxml)

convert qbxml object to hash

    o.inner_attributes

same as above but includes the top level containers

    o.attributes

retrieves attributes from nested objects

    o.attributes(true)

directly convert raw qbxml to a hash

    h = api.qbxml_to_hash(qbxml)

same as above but includes the top level containers 

    h = api.qbxml_to_hash(qbxml, true) 


### Ruby to QBXML
------------------------------------------------------------------------------

convert a hash to a qbxml object (automagically creates the top level containers)

    o = api.hash_to_obj(data_hash)

convert a qbxml object to raw qbxml

    o.to_qbxml.to_s

convert a hash directly to raw qbxml

    qbxml = api.hash_to_qbxml(data_hash)
