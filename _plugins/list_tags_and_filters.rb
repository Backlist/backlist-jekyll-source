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
      result = '<div class="book-block wrapper">'
      result += generate_meta(context)
      result += generate_links(context)
      result += generate_capsule(context)
      result += '</div>'

      result
    end

    private

      def generate_meta(context)
        if @book_id
          book = Book.new(@book_id,context.registers[:site])

          if book
            result = ''
            result += "<div class=\"book-meta-block\" id=\"#{@book_id}\">"

            if book.has_cover_image
              result += "<img class=\"cover\" src=\"/images/covers/#{@book_id[0]}/#{@book_id}-small.jpg\">"
            end

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
          else
            result = "ERROR: No book for the specified id '#{@book_id}'."
          end
        else
          result = "ERROR: An id was not specified for this book."
        end

        result
      end

      def generate_capsule(context)
        book = Book.new(@book_id, context.registers[:site])
        result = "<div markdown=\"1\">\n"
        if not book.reviews.nil?
          book.reviews.each do |review|
            if review[0] == @list_id
              result += Kramdown::Document.new(review[1]).to_html()
            end
          end
        end
        result += "</div>\n"
      end

      def generate_links(context)
        if @book_id
          book = Book.new(@book_id,context.registers[:site])

          if book
            result = ''
            result += '<ul class="affiliate-grid">'
            [:amzn, :powells, :indiebound, :betterworld, :direct, :oclc].each do |slug|
              result += "<li>#{book.build_link_for(slug)}</li>" if book.has_link_for?(slug)
            end
            result += '</ul>'
          else
            result = "ERROR: No book for the specified id '#{@book_id}."
          end
        else
          result = "ERROR: an id was not specified for this book."
        end

        result
      end

  end


end

Liquid::Template.register_filter(Jekyll::ListLinkFilter)

Liquid::Template.register_tag('list_section_header', Jekyll::ListSectionHeaderTag)
Liquid::Template.register_tag('bookblock', Jekyll::ListBookBlockTag)
