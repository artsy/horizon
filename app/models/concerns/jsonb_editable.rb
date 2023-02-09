# frozen_string_literal: true

# Allows editing (e.g., via ActiveAdmin) of jsonb columns. Use like:
#
# class SomeModel
#   include JsonbEditable
#   jsonb_editable :column
# end
#
# Then, update ActiveAdmin definitions to employ the "column_input"
# getter/setter instead of the "column" field.
#
module JsonbEditable
  extend ActiveSupport::Concern

  class_methods do
    def jsonb_editable(field_name, as: "#{field_name}_input")
      define_method("#{as}=") do |val|
        send("#{field_name}=", val.presence && JSON.parse(val))
      end

      define_method(as) do
        send(field_name)&.to_json
      end
    end
  end
end
