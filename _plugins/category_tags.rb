module Jekyll
  class CategoriesTableTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @group = text.strip
    end

    def render(context)
      site = context.registers[:site]
      categories = sorted_categories(context)

      result = ''
      result += '<ul class="categories"><!--'
      categories.each do |c|
        result += "--><li><a href=\"#{site.baseurl}category/#{c['id']}\">#{c['display_name']}</a></li><!--"
      end
      result += '--></ul>'

      return result
    end

    def sorted_categories(context)
      site = context.registers[:site]
      categories = []

      site.data['categories'].each do |c|
        if @group == 'all'
          categories << c
        else
          categories << c if c['group'] == @group
        end
      end

      categories = categories.sort { |a, b| a['display_name'] <=> b['display_name']}

      return categories
    end
  end
end

Liquid::Template.register_tag('categories_table', Jekyll::CategoriesTableTag)
