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
    def initialize(tag_name, text, tokens)
      @idx = text.to_i
      @labels = [
        ['Places to Start', 'places-to-start'],
        ['Digging In', 'digging-in'],
        ['New Moves', 'new-moves'],
        ['Voices and Lives', 'voices-and-lives']
      ]
    end

    def render(context)
      if @idx >= 0
        result = ''
        result += "<h2 id=\"#{@labels[@idx][1]}\">"
        result += '<div class="wrapper">'
        result += @labels[@idx][0]
        result += '</div>'
        result += '</h2>'
      else
        result = "ERROR: The index used to select a label for this header was not specified."
      end

      result
    end
  end

  class ListIntroBlockTag < Liquid::Tag
    def render(context)
      '<div class="intro-block wrapper">'
    end
  end

  class EndListIntroBlockTag < Liquid::Tag
    def render(context)
      '</div>'
    end
  end

  class ListBookBlockTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @book_id = text.split(',').first.strip
      @list_id = text.split(',').last.strip
      super
    end

    def render(context)
      result = '<div class="book-block wrapper">'
      result += generate_meta(context)
      result += generate_capsule(context)
      result += generate_links(context)
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

            result += '<div class="citation">'
            result += Kramdown::Document.new(
                          "### #{book.casual_citation}",
                          auto_ids: false
                          ).to_html()
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
              result += review[1]
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

  class EndListBookBlockTag < Liquid::Tag
    def render(context)
      '</div>'
    end
  end


end

Liquid::Template.register_filter(Jekyll::ListLinkFilter)

Liquid::Template.register_tag('list_section_header', Jekyll::ListSectionHeaderTag)
Liquid::Template.register_tag('bookblock', Jekyll::ListBookBlockTag)
Liquid::Template.register_tag('endbookblock', Jekyll::EndListBookBlockTag)
Liquid::Template.register_tag('introblock', Jekyll::ListIntroBlockTag)
Liquid::Template.register_tag('endintroblock', Jekyll::EndListIntroBlockTag)
