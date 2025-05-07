module StringKeyConcern
  extend ActiveSupport::Concern

  class_methods do
    def string_key(field, key)
      values = public_send(field)
      value = values[key]
      value ? values.key(value) : nil
    end
  end
end
