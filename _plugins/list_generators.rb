module Jekyll
  class ListBibliographyGenerator < Generator
    safe true

    def generate(site)
      books = collect_book_data_files(site)


      site.posts.docs.each do |post|
        if post.data['layout'] == 'list'
          content = build_bibtex_list(post.data['books'], site)
          f = File.new(File.join(site.source, post.permalink + '.bib'), 'w+')
          f.write(content)
          f.close()
          site.static_files << Jekyll::StaticFile.new(site, site.source, 'lists', post.permalink.split('/').last + '.bib')
        end
      end
    end

    private

      def build_bibtex_list(ids, site)
        result = ''

        ids.each do |id|
          site.collections['books'].docs.each do |book|
            if id == book.data['id']
              result += book.content + "\n"
            end
          end
        end

        return result
      end

      def collect_book_data_files(site)
        result = {}

        site.collections['books'].docs.each do |book|
          id = book.data['id']
          content = book.content

          result[id] = content
        end

        return result
      end
  end
end
