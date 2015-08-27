module Jekyll

  module PersonFullNameFilter
    def person_full_name(input)
      person = Person.new(input.strip, @context)

      if person
        result = person.full_name
      else
        result = "ERROR: There is no person associated with the specified id ‘#{input.strip}’."
      end

      result
    end
  end
end

Liquid::Template.register_filter(Jekyll::PersonFullNameFilter)