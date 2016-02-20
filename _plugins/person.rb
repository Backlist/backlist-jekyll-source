module Jekyll
  class Person
    attr_reader :first_name
    attr_reader :last_name
    attr_reader :bio

    def initialize(id, site)
      @id = id

      people = site.collections['people'].docs.select { |p| p.data['person_id'].to_s == id.to_s }
      person = people.first

      @last_name = person.data['last_name']
      @first_name = person.data['first_name']
      @bio = person.data['bio']
    end

    def full_name
      "#{@first_name} #{@last_name}"
    end
  end
end
