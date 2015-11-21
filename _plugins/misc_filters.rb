module Jekyll

  module MarkdownSpanFilter
    def markdown_span(input)
      Kramdown::Document.new(input.strip).to_html()[3..-6]
    end
  end

end

Liquid::Template.register_filter(Jekyll::MarkdownSpanFilter)
