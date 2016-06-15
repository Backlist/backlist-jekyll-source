module Jekyll
  class Book
    attr_reader :id
    
    attr_reader :full_citation
    attr_reader :casual_citation
    attr_reader :title

    attr_reader :authors
    attr_reader :editors
    attr_reader :translators

    attr_reader :reviews

    attr_reader :original_publication_year
    attr_reader :has_cover_image

    attr_reader :tokens

    def initialize(id, site)
      @id = id

      books = site.collections['books'].docs.select { |b| b.data['book_id'].to_s == id.to_s }
      book = books.first

      if !book
        return false
      end

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
            pair[0] << Person.new(id,site)
          end
        end
      end

      @reviews = []
      if book.data['reviews']
        book.data['reviews'].each do |review|
          @reviews << [review['list_id'], review['text']]
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

    def affiliate_url_for(slug)
      case slug
      when :amzn
        "http://www.amazon.com/exec/obidos/asin/#{@tokens[:amzn]}/ref=nosim/backlist0e-20"
      when :indiebound
        "http://www.indiebound.org/book/#{@tokens[:indiebound]}?aff=clionautics"
      when :powells
        "http://www.powells.com/book/#{@tokens[:powells]}?partnerid=44140&p_tx"
      when :oclc
        "http://worldcat.org/oclc/#{@tokens[:oclc]}"
      when :direct
        @tokens[:direct]
      else
        ''
      end
    end

    def build_link_for(slug)
      url = ''
      label = ''

      url = self.affiliate_url_for(slug)

      case slug
      when :amzn
        if @tokens[:amzn]
          label = 'Buy from Amazon'
          affiliate = true
        end
      when :indiebound
        if @tokens[:indiebound]
          label = 'Buy from Indiebound'
          affiliate = true
        end
      when :powells
        if @tokens[:powells]
          label = 'Buy from Powell’s'
          affiliate = true
        end
      when :direct
        if @tokens[:direct]
          label = 'Visit Publisher'
          affiliate = false
        end
      when :oclc
        if @tokens[:oclc]
          label = 'Find at Your Library'
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
