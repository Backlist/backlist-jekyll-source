module Jekyll
  class Film
    attr_reader :id

    attr_reader :full_citation
    attr_reader :casual_citation
    attr_reader :title

    attr_reader :directors
    attr_reader :producers

    attr_reader :reviews

    attr_reader :original_publication_year
    attr_reader :has_cover_image

    attr_reader :tokens
    attr_reader :links

    def initialize(id, site)
      @id = id

      films = site.collections['films'].docs.select { |f| f.data['id'].to_s == id.to_s }
      film = films.first

      if !film
        return false
      end

      @full_citation = film.data['full_citation']
      @casual_citation = film.data['casual_citation']
      @title = film.data['title']

      @directors = []
      @producers = []
      people_pairs = [[@directors, film.data['directors']],
                      [@producers, film.data['producers']]]

      people_pairs.each do |pair|
        if pair[1]
          pair[1].each do |id|
            pair[0] << Person.new(id,site)
          end
        end
      end

      @reviews = []
      if film.data['reviews']
        film.data['reviews'].each do |review|
          @reviews << [review['list_id'], review['text']]
        end
      end

      @original_publication_year = film.data['original_publication_year']
      @has_cover_image = film.data['has_cover_image']

      @tokens = {}

      @tokens[:oclc] = film.data['oclc'] if film.data['oclc']
      @tokens[:amzn] = film.data['amzn'] if film.data['amzn']
      @tokens[:isbn] = film.data['isbn'] if film.data['isbn']
      @tokens[:homepage] = film.data['homepage'] if film.data['homepage']

      @links = []

      if film.data['links']
        film.data['links'].each do |link|
          @links << { label: link['label'], url: link['url'] }
        end
      end
    end

    def affiliate_url_for(slug)
      case slug
      when :amzn
        "http://www.amazon.com/exec/obidos/asin/#{@tokens[:amzn]}/ref=nosim/backlist0e-20"
      when :oclc
        "http://worldcat.org/oclc/#{@tokens[:oclc]}"
      else
        ''
      end
    end

    def build_link_for(slug)
      url = ''
      label = ''

      if [:amzn, :oclc].include? slug
        url = self.affiliate_url_for(slug)
      elsif slug == :homepage
        url = @tokens[:homepage]
      end

      case slug
      when :amzn
        label = 'Buy from Amazon'
      when :oclc
        label = 'Find at Your Library'
      when :homepage
        label = "Homepage"
      else
        return "ERROR: There was not a link handler for the slug #{slug}."
      end

      if url.length > 0 and label.length > 0
        return "<a href=\"#{url}\" target=\"_blank\">#{label}</a>"
      end
    end

    def has_link_for?(slug)
      @tokens[slug]
    end
  end
end