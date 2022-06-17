# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'json'

class MayTapiService
  PRODUCT_ID = 'a71f9568-8975-40a7-8f26-ddd6a45c9b95'
  TOKEN = '8d4f4db4-ab8c-4e7d-b578-41e985064142'
  PHONE_ID = 20_207

  def initialize
    @url = URI("https://api.maytapi.com/api/#{PRODUCT_ID}/#{PHONE_ID}/sendMessage")
    @http = Net::HTTP.new(@url.host, @url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def send_message(phone, message)
    request = Net::HTTP::Post.new(@url)
    request['x-maytapi-key'] = TOKEN.to_s
    request['content-type'] = 'application/json'
    request.body = "{\"to_number\": \"#{phone}\",\"type\": \"text\",\"message\": \"#{message}\"}"

    response = @http.request(request)

    JSON.parse response.read_body
  end

  def get_logs
    request = Net::HTTP::Get.new("https://api.maytapi.com/api/#{PRODUCT_ID}/logs")
    request['x-maytapi-key'] = TOKEN.to_s
    request['content-type'] = 'application/json'

    response = @http.request(request)

    JSON.parse response.read_body
  end
end
