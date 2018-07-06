# frozen_string_literal: true

# IMDB scraping
class IML::IMDB
  attr_accessor :result
  attr_accessor :doc

  def initialize(query)
    query = CGI.escape(query)
    html = open("https://www.imdb.com/find?q=#{query}&ref_=nv_sr_fn", 'X-Forwarded-For' => '35.228.112.200').read
    @doc = Nokogiri::HTML(html)
    @result = []
    search
  end

  private

  def parsable_element(elem)
    elem.children[1] && (elem.css('i').first || elem.children[1].child.to_s) && elem.children[1].attr(:href) =~ /title/
  end

  def title_first_choice(elem)
    elem.css('i').first && elem.css('i').first.child.to_s.delete('"')
  end

  def parse_title(elem)
    title_first_choice(elem) || elem.children[1].child.to_s
  end

  def fetch_type(elem)
    elem.children[2].to_s.strip
  end

  def tv?(elem)
    fetch_type(elem).match(/\((?<year>\d{4})\) \(TV Series\)/) || false
  end

  def movie?(elem)
    fetch_type(elem).match(/\((?<year>\d{4})\)/) || false
  end

  def game?(elem)
    fetch_type(elem).match(/Video Game/) || false
  end

  def processable_elements
    @processable_elements ||= @doc.css('.result_text').select { |e| parsable_element(e) && !game?(e) }
  end

  def href(elem)
    elem.children[1].attr(:href)
  end

  def year(elem)
    fetch_type(elem).match(/\((?<year>\d{4})\)/).named_captures['year']
  end

  def search
    processable_elements.each do |elem|
      attrs = { title: parse_title(elem), href: href(elem), year: year(elem) }
      if tv?(elem)
        media = IML::TVSeries.new(attrs)
      elsif movie?(elem)
        media = IML::Movie.new(attrs)
      end
      result.push media
    end
  end
end
