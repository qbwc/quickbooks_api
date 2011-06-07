require 'rubygems'
require 'ruby2ruby' # must be version 1.2.1 of ruby2ruby
require 'nokogiri'
require 'active_support'
require 'active_support/core_ext'

module Quickbooks; end

require 'quickbooks/support'
require 'quickbooks/support/api'
require 'quickbooks/support/logger'
require 'quickbooks/support/qbxml'
require 'quickbooks/support/class_builder'
require 'quickbooks/qbxml_base'
require 'quickbooks/qbxml_parser'
require 'quickbooks/dtd_parser'
require 'quickbooks/api'
