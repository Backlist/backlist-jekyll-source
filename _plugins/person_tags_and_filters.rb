module Jekyll

  module AuthorBioFilter
    def author_bio(input)
      person = Person.new(input.strip, @context.registers[:site])

      if person
        name = "#{person.first_name} #{person.last_name}"
        bio = person.bio.gsub(name, "**#{name}**")
        result = Kramdown::Document.new(bio).to_html()
      else
        result = "<p>ERROR: There is no person associated with the specified id ‘#{input.strip}’.</p>"
      end

      result
    end
  end

  module PersonFullNameFilter
    def person_full_name(input)
      person = Person.new(input.strip, @context.registers[:site])

      if person
        result = person.full_name
      else
        result = "ERROR: There is no person associated with the specified id ‘#{input.strip}’."
      end

      result
    end
  end
end

Liquid::Template.register_filter(Jekyll::AuthorBioFilter)
Liquid::Template.register_filter(Jekyll::PersonFullNameFilter)
