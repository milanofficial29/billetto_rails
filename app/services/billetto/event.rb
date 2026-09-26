module Billetto
  class Event < Billetto::Client
    EventObj = Struct.new(:external_id, :title, :description, :image_url, :starts_at, :ends_at, :billetto_url, :location, :organiser_name, :available, keyword_init: true)

    def fetch_all_events
      results = []
      after   = nil

      loop do
        res = list_events(after: after)
        results.concat(res.fetch('data', []).map { |raw| build_event_obj(raw) })
        break unless res['has_more']

        after = extract_cursor(res['next_url'])
      end

      results
    end

    def list_events(after: nil, limit: 25)
      params = { limit: limit }
      params[:after] = after if after

      response = @client.get('/api/v3/public/events', params)
      handle_response(response)
    end

    private

    def handle_response(response)
      return response.body if response.success?

      case response.status
      when 401
        raise StandardError, 'Invalid API credentials'
      when 429
        raise StandardError, 'Rate limit exceeded'
      else
        raise StandardError, "Unexpected API response: #{response.status}"
      end
    end

    def build_event_obj(raw)
      EventObj.new(
        external_id:    raw['id'],
        title:          raw['title'],
        description:    sanitize(raw['description']),
        image_url:      raw['image_link'],
        starts_at:      raw['startdate'] ? Time.parse(raw['startdate']) : nil,
        ends_at:        raw['enddate'] ? Time.parse(raw['enddate']) : nil,
        billetto_url:   raw['url'],
        location:       full_address(raw['location']),
        organiser_name: raw.dig('organiser', 'name'),
        available:      raw['availability']
      )
    end

    def full_address(location)
      return nil unless location

      [location['location_name'], location['address_line'], location['city'], location['country']].reject(&:blank?).join(', ')
    end

    def sanitize(text)
      return nil unless text.present?

      stripped = ActionController::Base.helpers.strip_tags(text)
      CGI.unescapeHTML(stripped)
    end

    def extract_cursor(next_url)
      return nil unless next_url

      URI.decode_www_form(URI.parse(next_url).query.to_s).to_h['after']
    end

  end
end