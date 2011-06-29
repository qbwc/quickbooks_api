class Quickbooks::DtdParser < Quickbooks::QbxmlParser
  include Quickbooks::Parser::ClassBuilder

private

  def process_leaf_node(xml_obj, parent_class)
   attr_name, qb_type = parse_leaf_node_data(xml_obj)
    if parent_class
      add_casting_attribute(parent_class, attr_name, qb_type)
    end
  end

  def process_non_leaf_node(xml_obj, parent_class)
    klass = build_qbxml_class(xml_obj)
    attr_name = underscore(xml_obj)
    if parent_class
      add_strict_attribute(parent_class, attr_name, klass)
    end
    klass
  end

  #TODO: stub
  def process_comment_node(xml_obj, parent_class)
    parent_class
  end

  # helpers

  def build_qbxml_class(xml_obj)
    obj_name = xml_obj.name
    unless schema_namespace.const_defined?(obj_name)
      klass = Class.new(Quickbooks::Parser::QbxmlBase)
      schema_namespace.const_set(obj_name, klass) 
      xml_obj = set_required_attributes(xml_obj)
      add_xml_template(klass, xml_obj.to_xml)
    else
      klass = schema_namespace.const_get(obj_name)
    end
    klass
  end

  #FIXME: build in attribute parsing/support
  def set_required_attributes(xml_obj)
    required_attributes = required_xml_attributes
    xml_obj.attributes.each do |a,v|
      if required_attributes.keys.include?(a)
        xml_obj.set_attribute(a, required_attributes[a])
      else
        xml_obj.remove_attribute(a)
      end
    end
    xml_obj
  end

end
