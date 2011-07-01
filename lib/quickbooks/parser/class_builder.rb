module Quickbooks::Parser::ClassBuilder

private

def add_strict_attribute(klass, attr_name, type)
  add_attribute_type(klass, attr_name, type)
  
  eval <<-class_body
  class #{klass}
    attr_accessor :#{attr_name}

    def #{attr_name}=(obj)
      if self.respond_to?("#{attr_name}_type") 
        expected_type = self.class.#{attr_name}_type
        unless obj.is_a?(expected_type) || obj.is_a?(Array) 
          raise(TypeError, "expecting an object of type \#{expected_type}") 
        end
      end
      @#{attr_name} = obj
    end
  end
  class_body
end

def add_casting_attribute(klass, attr_name, type)
  type_casting_proc = klass::QB_TYPE_CONVERSION_MAP[type]
  ruby_type = type_casting_proc.call(nil).class
  add_attribute_type(klass, attr_name, ruby_type)

  eval <<-class_body
  class #{klass}
    attr_accessor :#{attr_name}

    def #{attr_name}=(obj)
      type_casting_proc = QB_TYPE_CONVERSION_MAP["#{type}"] 
      @#{attr_name} = type_casting_proc ? type_casting_proc.call(obj) : obj
    end
  end
  class_body
end

def add_attribute_type(klass, attr_name, type)
  eval <<-class_body
  class #{klass}
    @@#{attr_name}_type = #{type}
    def self.#{attr_name}_type
      #{type}
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
