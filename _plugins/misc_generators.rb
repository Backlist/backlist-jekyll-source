require 'json'

module Jekyll
  class HomepageRandomBookDataGenerator < Generator
    safe true

    def generate(site)
      books = []

      site.posts.docs.each do |post|
        if post.data['layout'] == 'list'
          author = Person.new(post.data['author'], site)

          post.data['sections'].each do |section|
            section['books'].each do |id|
              book = Book.new(id, site)

              if book.has_cover_image
                books << {
                  book_id: id,
                  list_title: post.data['title'],
                  list_permalink: post.data['permalink'],
                  author: author.full_name
                }
              end
            end
          end
        end
      end

      f = File.new(File.join(site.source, 'data-includes/homepage-featured-book-source.json'), 'w+')
      f.write(JSON.generate(books))
      f.close
      site.static_files << Jekyll::StaticFile.new(site, site.source, 'data-includes', 'homepage-featured-book-source.json')
    end

    def generate_old(site)
      lists = []
      books = []

      site.posts.docs.each do |post|
        if post.data['layout'] == 'list'
          lists << {
              id: post.data['id'],
              title: post.data['title'],
              permalink: post.data['permalink'] }
        end
      end

      # TODO: Refactor to avoid nested loops
      site.collections['books'].docs.each do |book|
        if defined? book.data['has_cover_image'] and book.data['has_cover_image']
          if defined? book.data['reviews']
            list_title = ''
            list_permalink = ''
            book.data['reviews'].each do |review|
              lists.each do |list|
                if list[:id] == review['list_id']
                  list_title = list[:title]
                  list_permalink = list[:permalink]
                  break
                end
              end
              books << {
                id: book.data['id'],
                list_title: list_title,
                list_permalink: list_permalink
              }
            end
          end
        end
      end

      f = File.new(File.join(site.source, 'data-includes/homepage-featured-book-source.json'), 'w+')
      f.write(JSON.generate(books))
      f.close
      site.static_files << Jekyll::StaticFile.new(site, site.source, 'data-includes', 'homepage-featured-book-source.json')
    end
  end

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
