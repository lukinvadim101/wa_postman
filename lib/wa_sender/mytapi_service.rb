require 'uri'
require 'net/http'
require 'openssl'

class MyTapi_Service
  PRODUCT_ID = 'a71f9568-8975-40a7-8f26-ddd6a45c9b95'
  TOKEN = '8d4f4db4-ab8c-4e7d-b578-41e985064142'
  PHONE_ID = 20207

  def initialize
    @url = URI("https://api.maytapi.com/api/#{PRODUCT_ID}/#{PHONE_ID}/sendMessage")

    @http = Net::HTTP.new(@url.host, @url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def sendMessage(phone, message)
    request = Net::HTTP::Post.new(@url)
    request["x-maytapi-key"] = "#{TOKEN}"
    request["content-type"] = 'application/json'
    request.body = "{\"to_number\": \"#{phone}\",\"type\": \"text\",\"message\": \"#{message}\"}"

    response = @http.request(request)
    puts response.read_body
  end
end