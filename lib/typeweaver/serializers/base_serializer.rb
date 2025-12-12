# frozen_string_literal: true

module TypeWeaver
  module Serializers
    class BaseSerializer
      def serialize(ir, output_dir)
        raise NotImplementedError, "Subclasses must implement #serialize"
      end

      protected

      def ensure_directory(path)
        FileUtils.mkdir_p(path)
      end

      def write_file(path, content)
        ensure_directory(File.dirname(path))
        File.write(path, content)
      end
    end
  end
end
