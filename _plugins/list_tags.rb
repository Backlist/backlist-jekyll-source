module Jekyll

  class ListSectionHeaderTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @idx = text.to_i
      @labels = [
        'Places to Start',
        'Digging In',
        'New Moves',
        'Voices and Lives'
      ]
    end

    def render(context)
      if @idx >= 0
        result = "## #{@labels[@idx]} ##"
      else
        result = "ERROR: The index used to select a label for this header was not specified."
      end

      result
    end
  end

  class ListBookBlockTag < Liquid::Tag
    def render(context)
      '<div class="book-block">'
    end
  end

  class EndListBookBlockTag < Liquid::Tag
    def render(context)
      # Specified in case there’s common footer code to be added later.
      '</div>'
    end
  end


end

Liquid::Template.register_tag('list_section_header', Jekyll::ListSectionHeaderTag)
Liquid::Template.register_tag('bookblock', Jekyll::ListBookBlockTag)
Liquid::Template.register_tag('endbookblock', Jekyll::EndListBookBlockTag)
