module Billetto
  class Client
    BASE_URL = 'https://billetto.dk/api/v3'

    def initialize(
      access_key_id:     ENV.fetch('BILLETTO_ACCESS_KEY_ID'),
      access_key_secret: ENV.fetch('BILLETTO_ACCESS_KEY_SECRET')
    )
      @access_key_id     = access_key_id
      @access_key_secret = access_key_secret

      @client ||= Faraday.new(url: BASE_URL) do |f|
        f.headers['Api-Keypair'] = "#{@access_key_id}:#{@access_key_secret}"
        f.headers['Accept']      = 'application/json'
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end
  end
end