module Jekyll
  class BibliographyPage < Page
    def initialize(site, base, dir, filter)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'bibliography.html')
      self.data['filter'] = filter.to_s
      self.data['title'] = 'TODO: temp title'
      self.data['header'] = 'Books'
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
        site.pages << BibliographyPage.new(site, site.source, File.join('bibliography', filter_dir), filter)
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
