# frozen_string_literal: true

module TypeWeaver
  module Generators
    class BaseGenerator
      def generate(file_path, ir)
        raise NotImplementedError, "Subclasses must implement #generate"
      end

      protected

      def read_file(file_path)
        File.read(file_path)
      end
    end
  end
end
