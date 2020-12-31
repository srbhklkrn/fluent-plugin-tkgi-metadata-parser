require "fluent/plugin/parser"
  
module Fluent::Plugin
  class TKGIMetadataParser < Parser
    # Register this parser as "tkgi_metadata"
    Fluent::Plugin.register_parser("tkgi_metadata", self)

    config_param :delimiter, :string, default: " "     # delimiter is configurable with " " as default

    config_param :es_mode,     :bool,   default: false 

    def configure(conf)
      super

      if @delimiter.length != 1
        raise ConfigError, "delimiter must be a single character. #{@delimiter} is not."
      end
    end

    def parse(text)
        # Delete first and last square bracket
        text.delete_prefix!("[")
        text.delete_suffix!("]")

        # Delete any double quotes
        text.gsub!(/"/,'')
        
        source, key_values = text.split(' ', 2)
        source, id = source.split('@', 2)
        record = {}
        
        key_values.split(' ').each do |kv|
          k, v = kv.split('=', 2)

          if @es_mode
            k.gsub!(/[\.]/, '_')
          end

          record[k] = v
        end

        record.merge!(source: source, source_id: id)
        
        yield nil, record
    end
  end
end