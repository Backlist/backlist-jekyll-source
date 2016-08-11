module Jekyll
  class BibliographyPage < Page
    PER_PAGE = 15

    def initialize(site, base, dir, filter, page_number, max_page)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'bibliography.html')
      self.data['filter'] = filter.to_s.upcase
      self.data['page_number'] = page_number
      self.data['max_page'] = max_page
      if filter == :all
        self.data['title'] = 'Books'
        self.data['header'] = 'Books'
      else
        self.data['title'] = "Books for ‘#{filter.to_s.upcase}’"
        self.data['header'] = "Books for ‘#{filter.to_s.upcase}’"
      end

      filtered_book_ids = BibliographyPage.book_ids_for_filter(filter, site)

      index = (page_number - 1) * PER_PAGE
      limit = PER_PAGE
      self.data['book_ids'] = filtered_book_ids[index...index + limit]
    end

      def self.book_ids_for_filter(filter, site)
        ids = []
        site.collections['books'].docs.each do |book|
          if defined? book.data['reviews']
            if filter == :all
              ids << book.data['book_id']
            else
              if book.data['full_citation'][0].downcase == filter.to_s.downcase
                ids << book.data['book_id']
              end
            end
          end
        end

        return ids
      end

      def self.count_books_for_filter(filter, site)
        counter = 0
        site.collections['books'].docs.each do |book|
          if defined? book.data['reviews']
            if filter == :all
              counter += 1
            else
              if book.data['full_citation'][0].downcase == filter.to_s.downcase
                counter += 1
              end
            end
          end
        end

        return counter
      end
  end

  class BibliographyPageGenerator < Generator
    safe true

    def generate(site)
      filters = [:all]
      filters += grab_valid_letters(site)

      filters.each do |filter|
        if filter == :all
          filter_dir = 'all'
        else
          filter_dir = filter.to_s.upcase
        end

        max_page = (BibliographyPage.count_books_for_filter(filter, site) / Float(BibliographyPage::PER_PAGE)).ceil
        for page_number in (1..max_page) do
          if page_number == 1
            # Add first page as the bar filter directory in addition to
            # numbered version that follows below
            site.pages << BibliographyPage.new(site, site.source, File.join('books', filter_dir), filter, page_number, max_page)
          end
          # Numbered URLs
          site.pages << BibliographyPage.new(site, site.source, File.join('books', filter_dir, page_number.to_s), filter, page_number, max_page)
        end
      end
    end

    private

      def grab_valid_letters(site)
        result = []

        site.collections['books'].docs.each do |book|
          letter = book.data['full_citation'][0].downcase.to_sym
          result << letter unless result.include? letter
        end

        return result
      end

  end
end
