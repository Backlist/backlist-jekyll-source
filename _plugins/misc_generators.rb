require 'json'

module Jekyll
  class Error404PageLinkDataGenerator < Generator
    safe true

    def generate(site)
      lists = []

      site.posts.docs.each do |post|
        if post.data['layout'] == 'list'
          lists << { title: post.data['title'], permalink: post.data['permalink'] }
          f = File.new(File.join(site.source, 'data-includes/404-page-links.json'), 'w+')
          f.write(JSON.generate(lists))
          f.close
          site.static_files << Jekyll::StaticFile.new(site, site.source, 'data-includes', '404-page-links.json')
        end
      end
    end
  end
end
