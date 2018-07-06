# frozen_string_literal: true

# IML's own re-implementation of hash with key/method funky patch and active_supports HashWithIndeifferetAccess
class IML::Hash < HashWithIndifferentAccess
  def method_missing(method_name)
    key?(method_name) ? self[method_name] : super
  end

  def respond_to_missing?(method_name, _include_private = false)
    key?(method_name) || false
  end
end
