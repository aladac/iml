# frozen_string_literal: true

class IML::Base < OpenStruct
  def initialize(hash = nil)
    super
    process
  end

  def process
    titleize
    delete_fields
  end

  def delete_fields
    each_pair do |k, v|
      delete_field(k) unless v
    end
  end

  def titleize
    self.title = IML::Text.new(title).to_title if title.is_a?(String)
    self.episode_title = IML::Text.new(episode_title).to_title if episode_title.is_a?(String)
    self.episode_title = nil if episode_title.to_s.empty?
    self
  end
end

class IML::Movie < IML::Base
  def movie?
    true
  end
end

class IML::TVSeries < IML::Base
  def tv?
    true
  end
end
