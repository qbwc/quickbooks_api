class Quickbooks::API
  include Quickbooks::Support

attr_accessor :dtd_parser, :qbxml_parser, :schema_type

def initialize(schema_type = nil, opts = {})
  @schema_type = schema_type
  use_disk_cache, log_level = opts.values_at(:use_disk_cache, :log_level)

  unless valid_schema_type?
    raise(ArgumentError, "schema type required: #{valid_schema_types.inspect}") 
  end

  @magic_key = get_magic_hash_key
  @dtd_file = get_dtd_file
  @dtd_parser = DtdParser.new(schema_type)
  @qbxml_parser = QbxmlParser.new(schema_type)

  load_qb_classes(use_disk_cache)
end

# CONVERSION FROM QBXML

def qbxml_to_hash(qbxml, include_container = false)
  qb_obj = qbxml_to_obj(qbxml)
  unless include_container
    qb_obj.inner_attributes
  else
    qb_obj.attributes
  end
end

# converts qbxml to a qb object
def qbxml_to_obj(qbxml)
  case qbxml
  when IO
    qbxml_parser.parse_file(qbxml)
  else
    qbxml_parser.parse(qbxml)
  end
end

# CONVERSION TO QBXML

def hash_to_qbxml(data)
  hash_to_qbxml_obj(data).to_qbxml.to_s
end

# converts a hash to a qb object
def hash_to_obj(data)
  qbxml_data = find_qbxml_hash(data)
  qb_obj = get_container_class.new(qbxml_data)
end
  
def qb_classes
  cached_classes
end

private 


def load_qb_classes(use_disk_cache = false)
  if use_disk_cache
    disk_cache = Dir["#{get_disk_cache_path}/*"]
    if disk_cache.empty?
      log.info "Warning: on disk schema cache is empty, rebuilding..."
      rebuild_schema_cache(false, true)
    else
      disk_cache.each {|file| require file }
    end
  else
    rebuild_schema_cache(false, false)
  end
end

# rebuilds schema cache in memory and writes to disk if desired
#
def rebuild_schema_cache(force = false, write_to_disk = false)
  dtd_parser.parse_file(@dtd_file) if (cached_classes.empty? || force)
  dump_cached_classes if write_to_disk
end

# writes dynamically generated api classes to disk
#
def dump_cached_classes
  cached_classes.each do |c|  
    File.open("#{get_disk_cache_path}/#{to_attribute_name(c)}.rb", 'w') do |f|
      f << Ruby2Ruby.translate(c)
    end
  end
end

def find_qbxml_hash(data)
  data.each do |k,v|
    if k == @magic_key
      return v
    elsif v.is_a? Hash
      return find_qbxml_hash(v)
    end
  end
end

# class methods

def self.log
  @@log ||= Logger.new(STDOUT, DEFAULT_LOG_LEVEL)
end


end
