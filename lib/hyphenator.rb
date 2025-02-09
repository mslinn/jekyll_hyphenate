require 'nokogiri'
require 'text/hyphen'

module Jekyll
  module Hyphenate
    # Lets get this party started
    class Hyphenator
      SOFT_HYPHEN_CHAR = "\u00ad".freeze
      SOFT_HYPHEN_ENTITY = '&shy;'.freeze

      def self.normal_word?(word)
        word !~ /&.*;/
      end

      def initialize(opts = {})
        language = opts[:language] || 'en_us'
        left = opts[:left] || 2
        right = opts[:right] || 2
        @hyphenator = Text::Hyphen.new(language: language,
                                       left: left,
                                       right: right)
        @hyphen = opts[:hyphen] || SOFT_HYPHEN_CHAR
        @selector = opts[:selector] || 'p'
      end

      def hyphenate(content)
        fragment = Nokogiri::HTML::DocumentFragment.parse(content)

        fragment.css(@selector).each do |el|
          el.traverse do |node|
            _x = node.to_s
            _y = node.to_html(encoding: 'UTF-8')
            _z = hyphenate_text(node.to_s) if node.text?
            _a = node.content
            _b = hyphenate_text(node.to_s) if node.text?
            node.content = hyphenate_text(node.to_s) if node.text?
          end
        end

        fragment.to_s
      end

      def hyphenate_text(text)
        words = text.split
        words.each do |word|
          next unless Hyphenator.normal_word?(word)

          regex = /#{Regexp.escape(word)}(?!\z)/
          hyphenated_word = @hyphenator.visualize(word, @hyphen)
          text.gsub!(regex, hyphenated_word)
        end
        text
      end
    end
  end
end
