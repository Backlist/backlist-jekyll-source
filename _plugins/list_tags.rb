module Jekyll

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
      '<div class="intro-block"><div class="wrapper">'
    end
  end

  class EndListIntroBlockTag < Liquid::Tag
    def render(context)
      '</div></div>'
    end
  end

  class ListBookBlockTag < Liquid::Tag
    def render(context)
      '<div class="book-block"><div class="wrapper">'
    end
  end

  class EndListBookBlockTag < Liquid::Tag
    def render(context)
      '</div></div>'
    end
  end


end

Liquid::Template.register_tag('list_section_header', Jekyll::ListSectionHeaderTag)
Liquid::Template.register_tag('bookblock', Jekyll::ListBookBlockTag)
Liquid::Template.register_tag('endbookblock', Jekyll::EndListBookBlockTag)
Liquid::Template.register_tag('introblock', Jekyll::ListIntroBlockTag)
Liquid::Template.register_tag('endintroblock', Jekyll::EndListIntroBlockTag)
