#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class String
  def titlecase
    split(/([[:alpha:]]+)/).map(&:capitalize).join
  end
end

class MemberList
  class Member
    POSITION_MAP = {
      'Minister for iTaukei Affairs, Sugar Industry and Foreign Affairs'                       => [
        'Minister for iTaukei Affairs',
        'Minister for Sugar Industry',
        'Minister for Foreign Affairs'
      ],
      'Minister for iTaukei Affairs, Sugar Industry, Foreign Affairs and Forestry'             => [
        'Minister for iTaukei Affairs',
        'Minister for Sugar Industry',
        'Minister for Foreign Affairs',
        'Minister for Forestry'
      ],
      'Minister for Economy, Civil Service and Communications'                                 => [
        'Minister for Economy',
        'Minister for Civil Service',
        'Minister for Communications'
      ],
      'Minister for Economy, Civil Service, Communications, Housing and Community Development' => [
        'Minister for Economy',
        'Minister for Civil Service',
        'Minister for Communications',
        'Minister for Housing and Community Development'
      ],
      'Minister for Education, Heritage and Arts and Local Government'                         => [
        'Minister for Education, Heritage and Arts',
        'Minister for Local Government'
      ],
    }.freeze

    NAME_MAP = {
      'Aiyaz Sayed Khaiyum' => 'Aiyaz Sayed-Khaiyum',
      'Rosy Ajbar'          => 'Rosy Akbar',
      'Praveen Bala'        => 'Parveen Bala',
    }.freeze

    def name
      NAME_MAP.fetch(raw_name, raw_name)
    end

    def position
      raw_position.flat_map { |posn| POSITION_MAP.fetch(posn, posn) }
    end

    private

    # Only appears in the image, but thankfully is also in the URL of it
    def raw_name
      img.split('/').last.delete_prefix('HON.-').split('-300').first.gsub('-', ' ').titlecase
    end

    def raw_position
      noko.parent.parent.css('.wpb_content_element p').first.text.tidy.split(/ and (?=Minister)/).map(&:tidy)
    end

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
