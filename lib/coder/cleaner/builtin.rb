require 'coder'

module Coder
  module Cleaner
    class Builtin
      def self.available?
        has_encoding? and mri?
      end

      def self.mri?
        !defined?(RUBY_ENGINE) or RUBY_ENGINE == 'ruby'
      end

      def self.supports?(encoding)
        Encoding.find(encoding)
      rescue ArgumentError
        false
      end

      def self.has_encoding?
        defined? Encoding.find          and
        defined? EncodingError          and
        String.method_defined? :encode  and
        String.method_defined? :force_encoding
      end

      def initialize(encoding)
        @encoding = encoding.to_s.upcase
        @dummy    = @encoding == 'UTF-8' ? 'UTF-16BE' : 'UTF-8'
        @dummy  ||= @encoding

        check_encoding
      end

      def clean(str)
        str = str.dup.force_encoding(@encoding)
        str.encode(@dummy, :undef => :replace, :invalid => :replace, :replace => "").encode(@encoding).gsub("\0".encode(@encoding), "")
      rescue EncodingError => e
        raise Coder::Error, e.message
      end

      private

      def check_encoding
        return if self.class.supports? @encoding
        raise Coder::InvalidEncoding, "unknown encoding name - #{@encoding}"
      end
    end
  end
end
