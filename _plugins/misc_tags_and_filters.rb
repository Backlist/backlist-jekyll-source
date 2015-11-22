module Jekyll

  class StripTag < Liquid::Block
    # Copied from https://github.com/aucor/jekyll-plugins

    def render(context)
      super.gsub /\n\s*\n/, "\n"
    end

  end

  module MarkdownSpanFilter
    def markdown_span(input)
      Kramdown::Document.new(input.strip).to_html()[3..-6]
    end
  end

end

Liquid::Template.register_tag('strip', Jekyll::StripTag)
Liquid::Template.register_filter(Jekyll::MarkdownSpanFilter)
