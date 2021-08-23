#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    # Only appears in the image, but thankfully is also in the URL of it
    def name
      img.split('/').last.delete_prefix('HON.-').split('-300').first.gsub('-', ' ')
    end

    def position
      noko.parent.parent.css('.wpb_content_element p').first.text.tidy.split(/ and (?=Minister)/).map(&:tidy)
    end

    private

    def img
      noko.css('img/@src').text.tidy
    end
  end

  class Members
    def member_container
      noko.css('.the_content .vc_figure')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
