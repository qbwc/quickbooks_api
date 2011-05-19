class Quickbooks::API
  include Quickbooks::Support

attr_accessor :dtd_parser, :qbxml_parser, :schema_type

def initialize(schema_type = nil, params = {})
  @schema_type = schema_type
  use_disk_cache, log_level = params[:use_disk_cache], params[:log_level]

  unless valid_schema_type?
    raise(ArgumentError, "schema type required, must be one of #{valid_schema_types.inspect}") 
  end

  @magic_key = get_magic_hash_key
  @dtd_file = get_dtd_file
  @dtd_parser = DtdParser.new(schema_type)
  @qbxml_parser = QbxmlParser.new(schema_type)

  load_qb_classes(use_disk_cache)
end

def parse_qbxml(qbxml)
  qbxml_parser.parse(qbxml)
end

def to_qbxml(data)
  raise(ArgumentError, "argument must be a hash with quickbooks object definition" unless data.is_a? Hash
  qbxml_data = find_qbxml_hash(data)
  get_container_class.new(qbxml_data)
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
  dtd_parser.parse_file(@dtd_file) if (cached_classes[schema_type].empty? || force)
  dump_cached_classes if write_to_disk
end

# writes dynamically generated api classes to disk
#
def dump_cached_classes
  cached_classes[schema_type].each do |c|  
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

def self.log
  @@log ||= Logger.new(STDOUT, DEFAULT_LOG_LEVEL)
end


end
