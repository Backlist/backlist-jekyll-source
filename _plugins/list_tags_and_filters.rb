module Jekyll

  module ListLinkFilter
    def list_link(input)
      list = List.new(input.strip, @context.registers[:site])

      if list
        result = "<a href=\"#{list.permalink}\">#{list.title}</a>"
      else
        result = "<p>ERROR: There is no list associated with the specified id ‘#{input.strip}’.</p>"
      end

      result
    end
  end

  class ListSectionHeaderTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @markup = markup
      @labels = [
        ['Places to Start', 'places-to-start'],
        ['Digging In', 'digging-in'],
        ['New Moves', 'new-moves'],
        ['Voices and Lives', 'voices-and-lives']
      ]
    end

    def render(context)
      idx = Liquid::Template.parse(@markup).render(context).to_i
      if idx >= 0
        result = ''
        result += "<h2 id=\"#{@labels[idx][1]}\">"
        result += '<div class="wrapper">'
        result += @labels[idx][0]
        result += '</div>'
        result += '</h2>'
      else
        result = "ERROR: The index used to select a label for this header was not specified."
      end

      result
    end
  end

  class ListBookBlockTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @markup = markup
      @book_id = ''
      @list_id = ''
      super
    end

    def render(context)
      text = Liquid::Template.parse(@markup).render(context)
      @book_id = text.split(',').first.strip
      @list_id = text.split(',').last.strip

      book = Book.new(@book_id, context.registers[:site])

      result = "<div id=\"#{@book_id}\" class=\"book-block wrapper\">"
      result += generate_meta(book, context)
      result += generate_capsule(book, context)
      result += generate_sidebar(book, :after, context)
      result += '</div>'

      result
    end

    private

      def generate_meta(book, context)
        result = ''
        result += '<div class="book-meta-block">'
        result += generate_sidebar(book, :before, context)
        result += '<div class="citation"><h3>'
        result += Kramdown::Document.new(
                      "#{book.casual_citation}",
                      auto_ids: false
                      ).to_html()[3..-6]
        book_link = "#{context.registers[:page]['permalink']}##{book.id}"
        result += "<a href='#{book_link}'><span class='icon'>"
        result +=
          Liquid::Template.parse('{% include svg/hyperlink.html %}').render(context)
        result += '</span></a>'
        result += '</div>'
        result += '</div>'

        result
      end

      def generate_capsule(book, context)
        result = "<div class=\"capsule\">\n"
        if not book.reviews.nil?
          book.reviews.each do |review|
            if review[0] == @list_id
              result += Kramdown::Document.new(review[1]).to_html()
            end
          end
        end
        result += "</div>\n"
      end

      def generate_sidebar(book, position, context)
        result = ''
        if position == :before
          result += '<div class="sidebar before">'
        elsif position == :after
          result += '<div class="sidebar after">'
        else
          result += '<div class="sidebar">'
        end
        if book.has_cover_image
          result += "<img class=\"cover\" src=\"/images/covers/#{@book_id[0]}/#{@book_id}-small.jpg\">"
        end
        result += generate_links(book, context)
        result += '<div class="clear-block"></div>'
        result += '</div>'

        result
      end

      def generate_links(book, context)
        result = ''

        if book.has_cover_image
          result += '<ul class="affiliate-grid">'
        else
          result += '<ul class="affiliate-grid no-cover">'
        end

        [:amzn, :powells, :indiebound, :betterworld, :direct, :oclc].each do |slug|
          result += "<li>#{book.build_link_for(slug)}</li>" if book.has_link_for?(slug)
        end
        result += '</ul>'

        result
      end

  end


end

Liquid::Template.register_filter(Jekyll::ListLinkFilter)

Liquid::Template.register_tag('list_section_header', Jekyll::ListSectionHeaderTag)
Liquid::Template.register_tag('bookblock', Jekyll::ListBookBlockTag)
