# MIT License

# Copyright (c) 2020 Saurabh Kulkarni

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

        # Replace any whitespaces with `_` if exists inside the double quotes
        text.gsub!(/\s+(?=(?:(?:[^"]*"){2})*[^"]*"[^"]*$)/,'_')

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