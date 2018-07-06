# frozen_string_literal: true

# IML's own re-implementation of hash with key/method funky patch and active_supports HashWithIndeifferetAccess
class IML::Hash < HashWithIndifferentAccess
  # Way to access Hash keys by method_name
  def method_missing(method_name)
    key?(method_name) ? self[method_name] : super
  end

  # @return <Boolean> Responds true for methods that have names of Hash keys
  def respond_to_missing?(method_name, _include_private = false)
    key?(method_name) || false
  end
end
