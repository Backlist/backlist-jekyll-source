module Jekyll
  class AudioRecording
    attr_reader :id

    attr_reader :full_citation
    attr_reader :casual_citation
    attr_reader :title

    attr_reader :artists
    attr_reader :producers

    attr_reader :reviews

    attr_reader :original_publication_year
    attr_reader :has_cover_image

    attr_reader :tokens
    attr_reader :links

    def initialize(id, site)
      @id = id

      audio_recordings = 
        site.collections['audio_recordings'].docs.select { |r| r.data['recording_id'].to_s == id.to_s }
      audio_recording = audio_recordings.first

      if !audio_recording
        return false
      end

      @full_citation = audio_recording['full_citation']
      @casual_citation = audio_recording['casual_citation']
      @title = audio_recording['title']

      @artists = []
      @producers = []
      people_pairs = [[@artists, audio_recording.data['artists']],
                      [@producers, audio_recording.data['producers']]]

      people_pairs.each do |pair|
        if pair[1]
          pair[1].each do |id|
            pair[0] << Person.new(id, site)
          end
        end
      end

      @reviews = []
      if audio_recording.data['reviews']
        audio_recording.data['reviews'].each do |review|
          @reviews << [review['list_id'], review['text']]
        end
      end

      @original_publication_year = audio_recording.data['original_publication_year']
      @has_cover_image = audio_recording.data['has_cover_image']

      @tokens = {}

      @tokens[:oclc] = audio_recording.data['oclc'] if audio_recording.data['oclc']
      @tokens[:amzn] = audio_recording.data['amzn'] if audio_recording.data['amzn']
      @tokens[:isbn] = audio_recording.data['isbn'] if audio_recording.data['isbn']

      @links = []

      if audio_recording.data['links']
        audio_recording.data['links'].each do |link|
          @links << { label: link['label'], url: link['url'] }
        end
      end
    end

    def affiliate_url_for(slug)
      case slug
      when :amzn
        "http://www.amazon.com/exec/obidos/asin/#{@tokens[:amzn]}/ref=nosim/backlist0e-20"
      when :oclc
        "http://worldcat.org/oclc/#{@tokens[:oclc]}"
      else
        ''
      end
    end

    def build_link_for(slug)
      url = ''
      label = ''

      if [:amzn, :oclc].include? slug
        url = self.affiliate_url_for(slug)
      elsif slug == :homepage
        url = @tokens[:homepage]
      end

      case slug
      when :amzn
        label = 'Buy from Amazon'
      when :oclc
        label = 'Find at Your Library'
      else
        return "ERROR: There was not a link handler for the slug #{slug}"
      end

      if url.length > 0 and label.length > 0
        return "<a href=\"#{url}\" target=\"_blank\">#{label}</a>"
      end
    end

    def has_link_for?(slug)
      @tokens[slug]
    end
  end
end