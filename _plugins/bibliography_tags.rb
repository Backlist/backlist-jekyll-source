module Jekyll
  class FilterTableTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @possible_filters = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l,
                            :m, :n, :o, :p, :q, :r, :s, :t, :u, :v, :w,
                            :x, :y, :z]
      super
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      alpha_filters = grab_filters(site)

      result = '<ul class="bibliography-filters">'
      if page['filter'] == 'all'
        result += '<li><span class="here">All</span></li>'
      else
        result += '<li><a href="/books/all">All</a></li>'
      end
      alpha_filters.each do |filter|
        if filter.to_s == page['filter']
          result += "<li><span class=\"here\">#{filter.to_s.upcase}</span></li>"
        else
          result += "<li><a href=\"/books/#{filter.to_s.upcase}\">#{filter.to_s.upcase}</a></li>"
        end
      end
      result += '</ul>'
    end

    private

      def grab_filters(site)
        filters = []

        site.collections['books'].docs.each do |book|
          test_filter = book['full_citation'][0].downcase.to_sym
          if not filters.include? test_filter
            filters << test_filter
          end
        end

        return filters
      end
  end

  Liquid::Template.register_tag('filter_table', Jekyll::FilterTableTag)
end
