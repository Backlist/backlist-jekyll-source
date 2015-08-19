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
      @tokens[:isbn] = book.data['isbn'] if book.data['isbn']
      @tokens[:betterworld] = book.data['betterworld'] if book.data['betterworld']
      @tokens[:betterworld_image] = book.data['betterworld_image'] if book.data['betterworld_image']
    end

    def build_link_for(slug)
      url = ''
      label = ''

      case slug
      when :amzn
        if @tokens[:amzn]
          url = "http://www.amazon.com/exec/obidos/asin/#{@tokens[:amzn]}/ref=nosim/theappe0c-20" # TODO: replace Appendix affiliate token
          label = 'Buy from Amazon'
        end
      when :indiebound
        if @tokens[:isbn]
          url = "http://www.indiebound.org/book/#{@tokens[:isbn]}?aff=appendixjournal" # TODO: replace Appendix affiliate token
          label = 'Buy from Indiebound'
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
        end
      else
        return "ERROR: There was not a link handler for the slug '#{slug}'."
      end

      if url.length > 0 and label.length > 0
        "<a href='#{url}' target='_blank'>#{label}</a>"
      else
        "ERROR: The link constructor for the slug '#{slug}' was poorly defined."
      end
    end
    
    def has_link_for?(slug)
      if slug == :betterworld
        @tokens[:betterworld] and @tokens[:betterworld_image]
      elsif slug == :indiebound
        @tokens[:isbn]
      else
        @tokens[slug]
      end
    end

  end
end