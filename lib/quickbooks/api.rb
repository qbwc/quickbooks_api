class Quickbooks::API
  include Quickbooks
  include Quickbooks::Support

attr_accessor :dtd_parser, :qbxml_parser, :dtd_file

XML_SCHEMA_PATH = File.join(API_ROOT, 'xml_schema')   
RUBY_SCHEMA_PATH = File.join(API_ROOT, 'ruby_schema') 

DTD_MAP = {
  :qb    => "qbxmlops70.xml", 
  :qbpos => "qbposxmlops30.xml"
}

USE_DISK_SCHEMA_CACHE = false
LOG_LEVEL = 1


# private

def initialize(schema_type = nil)
  unless DTD_MAP.include?(schema_type)
    raise(ArgumentError, "schema type required, must be [ :qb | :qbpos ]") 
  end
  @dtd_file = "#{XML_SCHEMA_PATH}/#{DTD_MAP[schema_type]}"
  @dtd_parser = DtdParser.new
  @qbxml_parser = QbxmlParser.new

  load_qb_classes
end

def load_qb_classes
  if USE_DISK_SCHEMA_CACHE
    disk_cache = Dir["#{RUBY_SCHEMA_PATH}/*"]
    if disk_cache.empty?
      log.info "Warning: on disk schema cache is empty, rebuilding..."
      rebuild_schema_cache(true)
    else
      disk_cache.each {|file| require file }
    end
  else
    rebuild_schema_cache(false)
  end
end

# rebuilds schema cache in memory and writes to disk if desired
#
def rebuild_schema_cache(write_to_disk, force = false)
  dtd_parser.parse_file(@dtd_file) if (cached_classes.empty? || force)
  dump_cached_classes if write_to_disk
end

def dump_cached_classes(path = RUBY_SCHEMA_PATH)
  cached_classes.each do |c|  
    File.open("#{path}/#{to_attribute_name(c)}.rb", 'w') do |f|
      f << Ruby2Ruby.translate(c)
    end
  end
end


end
