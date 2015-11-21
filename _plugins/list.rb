module Jekyll
  class List
    attr_reader :id
    attr_reader :title
    attr_reader :timestamp
    attr_reader :permalink
    attr_reader :author

    def initialize(id, site)
      @id = id

      posts = site.posts.docs.select { |p| p.data['id'].to_s == id.to_s }
      post = posts.first

      @title = post.data['title']
      # TODO: Add timestamp functionality
      @permalink = post.data['permalink']
      @author = Person.new(post.data['author'], site)

      # puts post.categories
      # TODO: Categories
    end
  end
end
