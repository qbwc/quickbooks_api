require 'active_support/core_ext'

module Quickbooks::Support::Inflection

  def underscore(obj)
    name = \
      case obj
      when Class
        obj.simple_name
      when Nokogiri::XML::Element
        obj.name
      else
        obj.to_s
      end
    name.underscore
  end

end
