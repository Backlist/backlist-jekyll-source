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

  class ListSourceBlockTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @markup = markup
      @id = ''
      @list_id = ''
      @type = ''
      super
    end

    def render(context)
      text = Liquid::Template.parse(@markup).render(context)
      @id = text.split(',').first.strip
      @type = text.split(',')[1].strip
      @list_id = text.split(',').last.strip

      case @type
      when 'book'
        source = Book.new(@id, context.registers[:site])
      when 'film'
        source = Film.new(@id, context.registers[:site])
      end

      result = "<div id=\"#{@id}\" class=\"source-block wrapper\">"
      result += generate_meta(source, context)
      result += generate_capsule(source, context)
      result += generate_sidebar(source, :after, context)
      result += '</div>'

      result
    end

    private

      def generate_meta(source, context)
        result = ''
        result += '<div class="source-meta-block">'
        result += generate_sidebar(source, :before, context)
        result += "<div class=\"citation\"><h3><a href=\"#{source.affiliate_url_for(:amzn)}\" target=\"_blank\">"
        result += Kramdown::Document.new(
                      "#{source.casual_citation}",
                      auto_ids: false
                      ).to_html()[3..-6]
        source_link = "#{context.registers[:page]['permalink']}##{source.id}"
        result += "</a><a href='#{source_link}' class=\"icon\"><span class='icon'>"
        result +=
          Liquid::Template.parse('{% include svg/hyperlink.html %}').render(context)
        result += '</span></a>'
        result += '</div>'
        result += '</div>'

        result
      end

      def generate_capsule(source, context)
        result = "<div class=\"capsule\">\n"
        if not source.reviews.nil?
          source.reviews.each do |review|
            if review[0] == @list_id
              result += Kramdown::Document.new(review[1]).to_html()
            end
          end
        end
        result += "</div>\n"
      end

      def generate_sidebar(source, position, context)
        result = ''
        if position == :before
          result += '<div class="sidebar before">'
        elsif position == :after
          result += '<div class="sidebar after">'
        else
          result += '<div class="sidebar">'
        end
        if source.has_cover_image
          result += "<a href=\"#{source.affiliate_url_for(:amzn)}\" target=\"_blank\"><img class=\"cover\" src=\"/images/covers/#{@id[0]}/#{@id}-small.jpg\"></a>"
        end
        result += "<a href=\"#{source.affiliate_url_for(:amzn)}\" target=\"_blank\" class=\"buy-button\">Buy Now</a>"
        result += generate_links(source, context)
        result += '<div class="clear-block"></div>'
        result += '</div>'

        result
      end

      def generate_links(source, context)
        result = ''

        if source.has_cover_image
          result += '<ul class="affiliate-grid">'
        else
          result += '<ul class="affiliate-grid no-cover">'
        end

        [:amzn, :powells, :indiebound, :betterworld, :direct, :oclc].each do |slug|
          result += "<li>#{source.build_link_for(slug)}</li>" if source.has_link_for?(slug)
        end
        result += '</ul>'

        result
      end

  end


end

Liquid::Template.register_filter(Jekyll::ListLinkFilter)

Liquid::Template.register_tag('list_section_header', Jekyll::ListSectionHeaderTag)
Liquid::Template.register_tag('sourceblock', Jekyll::ListSourceBlockTag)
