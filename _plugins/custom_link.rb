module Jekyll
  class CustomLink
    attr_reader :id

    attr_reader :full_citation
    attr_reader :casual_citation
    attr_reader :title

    attr_reader :authors

    attr_reader :reviews

    attr_reader :original_publication_year

    attr_reader :main_link
    attr_reader :links

    def initialize(id, site)
      @id = id

      links = site.collections['links'].docs.select { |l| l.data['id'].to_s == id.to_s }
      link = links.first

      if !link
        return false
      end

      @full_citation = link.data['full_citation']
      @casual_citation = link.data['casual_citation']
      @title = link.data['title']

      @authors = []
      link.data['authors'].each do |id|
        @authors << Person.new(id, site)
      end

      @reviews = []
      if link.data['reviews']
        link.data['reviews'].each do |review|
          @reviews << [review['list_id'], review['text']]
        end
      end

      @main_link = link.data['main_link']
      @original_publication_year = link.data['original_publication_year']

      @links = []
      if link.data['links']
        link.data['links'].each do |link|
          @links << { label: link['label'], url: link['url'] }
        end
      end
    end

    def has_link_for?(slug)
      false
    end

  end
end