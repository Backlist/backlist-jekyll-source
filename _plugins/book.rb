module Jekyll
  class Book
    attr_reader :full_citation
    attr_reader :casual_citation
    attr_reader :title

    attr_reader :authors
    attr_reader :editors
    attr_reader :translators

    attr_reader :original_publication_year
    attr_reader :has_cover_image

    attr_reader :tokens

    def initialize(id, context)
      @id = id

      site = context.registers[:site]
      books = site.collections['books'].docs.select { |b| b.data['id'].to_s == id.to_s }
      book = books.first

      @full_citation = book.data['full_citation']
      @casual_citation = book.data['casual_citation']
      @title = book.data['title']

      @authors = []
      @editors = []
      @translators = []
      people_pairs = [[@authors, book.data['authors']], 
                        [@editors, book.data['editors']],
                        [@translators, book.data['translators']]]

      people_pairs.each do |pair|
        if pair[1]
          pair[1].each do |id|
            pair[0] << Person.new(id,context)
          end
        end
      end

      @original_publication_year = book.data['original_publication_year']
      @has_cover_image = book.data['has_cover_image']

      @tokens = {}

      @tokens[:oclc] = book.data['oclc'] if book.data['oclc']
      @tokens[:amzn] = book.data['amzn'] if book.data['amzn']
      @tokens[:indiebound] = book.data['indiebound'] if book.data['indiebound']
      @tokens[:powells] = book.data['powells'] if book.data['powells']
      @tokens[:direct] = book.data['direct'] if book.data['direct']
      @tokens[:betterworld] = book.data['betterworld'] if book.data['betterworld']
      @tokens[:betterworld_image] = book.data['betterworld_image'] if book.data['betterworld_image']
    end

    def build_link_for(slug)
      url = ''
      label = ''

      case slug
      when :amzn
        if @tokens[:amzn]
          url = "http://www.amazon.com/exec/obidos/asin/#{@tokens[:amzn]}/ref=nosim/clionautics-20"
          label = 'Buy from Amazon'
          affiliate = true
        end
      when :indiebound
        if @tokens[:indiebound]
          url = "http://www.indiebound.org/book/#{@tokens[:isbn]}?aff=appendixjournal" # TODO: replace Appendix affiliate token
          label = 'Buy from Indiebound'
          affiliate = true
        end
      when :powells
        if @tokens[:powells]
          url = "http://www.powells.com/book/#{@tokens[:powells]}?partnerid=44140&p_wgt"
          label = 'Buy from Powell’s'
          affiliate = true
        end
      when :direct
        if @tokens[:direct]
          url = @tokens[:direct]
          label = 'Buy from Publisher'
          affiliate = false
        end
      when :betterworld
        if @tokens[:betterworld] and @tokens[:betterworld_image]
          url = @tokens[:betterworld]
          label = "Buy from BetterWorld Books<img src='#{@tokens[:betterworld_image]}' width='1' height='1' border='0' />"
        end
      when :oclc
        if @tokens[:oclc]
          url = "http://worldcat.org/oclc/#{@tokens[:oclc]}"
          label = 'Find at your library'
          affiliate = false
        end
      else
        return "ERROR: There was not a link handler for the slug '#{slug}'."
      end

      if url.length > 0 and label.length > 0
        if affiliate
          return "<a href=\"#{url}\" class=\"affiliate\" target=\"_blank\">#{label}<span></span></a>"
        else
          return "<a href=\"#{url}\" target=\"_blank\">#{label}<span></span></a>"
        end
      else
        return "ERROR: The link constructor for the slug '#{slug}' was poorly defined."
      end
    end
    
    def has_link_for?(slug)
      if slug == :betterworld
        @tokens[:betterworld] and @tokens[:betterworld_image]
      else
        @tokens[slug]
      end
    end

  end
end