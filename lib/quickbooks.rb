# $LOAD_PATH.unshift "#{File.dirname(File.expand_path(__FILE__))}/../lib/"
require 'rubygems'

module Quickbooks; end
module Quickbooks::QBXML; end
module Quickbooks::QBPOSXML; end
module Quickbooks::Support; end
module Quickbooks::Parser; end

require 'quickbooks/support/monkey_patches'
require 'quickbooks/support/inflection'
require 'quickbooks/logger'
require 'quickbooks/config'
require 'quickbooks/parser/xml_parsing'
require 'quickbooks/parser/xml_generation'
require 'quickbooks/parser/class_builder'
require 'quickbooks/parser/qbxml_base'
require 'quickbooks/qbxml_parser'
require 'quickbooks/dtd_parser'
require 'quickbooks/api'
