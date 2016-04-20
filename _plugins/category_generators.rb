require 'json'

module Jekyll
  class CategoryPostsDataPageGenerator < Generator
    safe true

    def generate(site)
      data_includes = File.join(site.source, 'data-includes')
      categories_includes = File.join(site.source, 'data-includes', 'categories')

      Dir.mkdir(data_includes) unless Dir.exist?(data_includes)
      Dir.mkdir(categories_includes) unless Dir.exist?(categories_includes)

      site.data['categories'].each do |category|
        lists = []

        site.categories[category['id']].each do |post|
          author = Person.new(post.data['author'], site)

          lists << {
            list_title: post.data['title'],
            list_permalink: post.data['permalink'],
            author: author.full_name
          }
        end

        collection = {
          "display_name": category['display_name'],
          "contents": lists
        }

        f = File.new(File.join(site.source, 'data-includes', 
                     'categories', "#{category['id']}.json"), 'w+')
        f.write(JSON.generate(collection))
        f.close
        site.static_files << Jekyll::StaticFile.new(site, site.source, File.join('data-includes', 'categories'), "#{category['id']}.json")
      end
    end
  end

  class CategoryPage < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category.html')
      self.data['category'] = category['id']
      self.data['title'] = category['display_name']
      self.data['header'] = "Browse Lists for ‘#{category['display_name']}’"
    end
  end

  class CategoryPageGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'category'
        dir = 'category'
        site.data['categories'].each do |category|
          site.pages << CategoryPage.new(site, site.source, File.join(dir, category['id']), category)
        end
      end
    end
  end
end
