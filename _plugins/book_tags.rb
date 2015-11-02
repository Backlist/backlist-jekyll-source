module Jekyll


  class BookCapsuleTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @review = text
      super
    end

    def render(context)
      Kramdown::Document.new(@review).to_html()
    end
  end


  class BookMetaTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @id = text.strip
      super
    end

    def render(context)
      if @id
        book = Book.new(@id,context)

        if book
          result = ''
          result += '<div class="book-meta-block">'

          if book.has_cover_image
            result += "<img class=\"cover\" src=\"/images/covers/#{@id[0]}/#{@id}-small.jpg\">"
          end
          
          result += '<div class="citation">'
          result += Kramdown::Document.new(
                        "### #{book.casual_citation}", 
                        auto_ids: false
                        ).to_html()
          result += '</div>'


          result += '</div>'
        else
          result = "ERROR: No book for the specified id '#{@id}'."
        end
      else
        result = "ERROR: An id was not specified for this book."
      end

      result
    end
  end

  class BookLinksTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @id = text.strip
      super
    end

    def render(context)
      if @id
        book = Book.new(@id,context)

        if book
          result = ''
          result += '<ul class="affiliate-grid">'
          [:amzn, :powells, :indiebound, :betterworld, :direct, :oclc].each do |slug|
            result += "<li>#{book.build_link_for(slug)}</li>" if book.has_link_for?(slug)
          end
          result += '</ul>'
        else
          result = "ERROR: No book for the specified id '#{@id}."
        end
      else
        result = "ERROR: an id was not specified for this book."
      end

      result
    end
  end
end

Liquid::Template.register_tag('book_capsule', Jekyll::BookCapsuleTag)
Liquid::Template.register_tag('book_meta', Jekyll::BookMetaTag)
Liquid::Template.register_tag('book_links', Jekyll::BookLinksTag)
