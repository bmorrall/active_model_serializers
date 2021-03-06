module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      module Error
        # rubocop:disable Style/AsciiComments
        UnknownSourceTypeError = Class.new(ArgumentError)

        # Builds a JSON API Errors Object
        # {http://jsonapi.org/format/#errors JSON API Errors}
        #
        # @param [ActiveModel::Serializer::ErrorSerializer]
        # @return [Array<Symbol, Array<String>] i.e. attribute_name, [attribute_errors]
        def self.resource_errors(error_serializer)
          error_serializer.as_json.flat_map do |attribute_name, attribute_errors|
            attribute_error_objects(attribute_name, attribute_errors)
          end
        end

        # definition:
        #   JSON Object
        #
        # properties:
        #   ☐ id      : String
        #   ☐ status  : String
        #   ☐ code    : String
        #   ☐ title   : String
        #   ☑ detail  : String
        #   ☐ links
        #   ☐ meta
        #   ☑ error_source
        #
        # description:
        #   id     : A unique identifier for this particular occurrence of the problem.
        #   status : The HTTP status code applicable to this problem, expressed as a string value
        #   code   : An application-specific error code, expressed as a string value.
        #   title  : A short, human-readable summary of the problem. It **SHOULD NOT** change from
        #     occurrence to occurrence of the problem, except for purposes of localization.
        #   detail : A human-readable explanation specific to this occurrence of the problem.
        def self.attribute_error_objects(attribute_name, attribute_errors)
          attribute_errors.map do |attribute_error|
            {
              source: error_source(:pointer, attribute_name),
              detail: attribute_error
            }
          end
        end

        # description:
        #   oneOf
        #     ☑ pointer   : String
        #     ☑ parameter : String
        #
        # description:
        #   pointer: A JSON Pointer RFC6901 to the associated entity in the request document e.g. "/data"
        #   for a primary data object, or "/data/attributes/title" for a specific attribute.
        #   https://tools.ietf.org/html/rfc6901
        #
        #   parameter: A string indicating which query parameter caused the error
        def self.error_source(source_type, attribute_name)
          case source_type
          when :pointer
            {
              pointer: ActiveModelSerializers::JsonPointer.new(:attribute, attribute_name)
            }
          when :parameter
            {
              parameter: attribute_name
            }
          else
            fail UnknownSourceTypeError, "Unknown source type '#{source_type}' for attribute_name '#{attribute_name}'"
          end
        end
        # rubocop:enable Style/AsciiComments
      end
    end
  end
end
