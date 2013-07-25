require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/blank'

module ActionView
  # = Active Model Helpers
  module Helpers
    module ActiveModelHelper
    end

    module ActiveModelInstanceTag
      def object
        @active_model_object ||= begin
          object = super
          object.respond_to?(:to_model) ? object.to_model : object
        end
      end

      %w(content_tag to_date_select_tag to_datetime_select_tag to_time_select_tag).each do |meth|
        module_eval "def #{meth}(*) error_wrapping(super) end", __FILE__, __LINE__
      end

      def tag(type, options, *)
        tag_generate_errors?(options) ? error_wrapping(super) : super
      end

      def error_wrapping(html_tag)
        if object_has_errors?
          Base.field_error_proc.call(html_tag, self)
        else
          html_tag
        end
      end

      def error_message
        object.errors[@method_name]
      end

      private

      def object_has_errors?
        object.respond_to?(:errors) && object.errors.respond_to?(:full_messages) && error_message.any?
      end

      def tag_generate_errors?(options)
        options['type'] != 'hidden'
      end
    end
  end
end
