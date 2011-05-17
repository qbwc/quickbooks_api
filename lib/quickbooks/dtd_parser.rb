class Quickbooks::DtdParser < Quickbooks::QbxmlParser

COMMENT_START = "<!--"
COMMENT_END = "-->"
COMMENT_MATCHER = /\A#{COMMENT_START}.*#{COMMENT_END}\z/


def parse_file(qbxml_file)
  parse(
    cleanup_qbxml(
      File.read(qbxml_file)))
end

# private

# remove all comment lines and empty nodes
def cleanup_qbxml(qbxml)
  qbxml = qbxml.split('\n')
  qbxml.map! { |l| l.strip }
  qbxml.reject! { |l| l =~ COMMENT_MATCHER }
  qbxml.join('')
end

def process_leaf_node(xml_obj, parent_class)
 attr_name, qb_type = parse_leaf_node_type(xml_obj)
  if parent_class
    add_casting_attribute(parent_class, attr_name, qb_type)
  end
end

def parse_leaf_node_type(xml_obj)
  attr_name = to_attribute_name(xml_obj)
  text_node = xml_obj.children.first
  [attr_name, text_node.text]
end


def process_non_leaf_node(xml_obj, parent_class)
  klass = build_qbxml_class(xml_obj)
  attr_name = to_attribute_name(klass)
  if parent_class
    add_strict_attribute(parent_class, attr_name, klass)
  end
  klass
end

def build_qbxml_class(xml_obj)
  obj_name = xml_obj.name
  unless qbxml_class_defined?(obj_name) 
    klass = Class.new(Qbxml::Base)
    Qbxml.const_set(obj_name, klass) 
    add_xml_template(klass, xml_obj.to_xml)
  else
    klass = Qbxml.const_get(obj_name)
  end
  klass
end

def process_comment_node(xml_obj, parent_class)
  parent_class
end

def qbxml_class_defined?(name)
  Qbxml.constants.include?(name)
end

# eval goodness
#
def add_strict_attribute(klass, attr_name, type)
  log.debug "add_strict_attribute#params: #{[klass, attr_name, type].inspect}"
  eval <<-class_body
  class #{klass}
    attr_accessor :#{attr_name}

    def #{attr_name}=(obj)
      if obj.class == #{type}
        @#{attr_name} = obj
      elsif obj.is_a?(Hash)
        @#{attr_name} = #{type}.new(obj)
      else
        raise(TypeError, "expecting an object of type #{type}") 
      end
    end
  end
  class_body
end

def add_casting_attribute(klass, attr_name, type)
  eval <<-class_body
  class #{klass}
    attr_accessor :#{attr_name}

    def #{attr_name}=(obj)
      validation_proc = QB_TYPE_CONVERSION_MAP['#{type}']
      @#{attr_name} = validation_proc ? validation_proc.call(obj) : obj
    end
  end
  class_body
end

def add_xml_template(klass, xml_template)
  eval <<-class_body
  class #{klass}
    def self.xml_template
      #{xml_template.dump}
    end
  end
  class_body
end


end
