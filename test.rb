# In a Rails console or test script
require 'net/http'
require 'uri'

def test_ssl_connection
  ca_file = '/certs/grpc-ca.crt'
  uri = URI.parse("https://topaz:9292")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  http.ca_file = ca_file

  request = Net::HTTP::Get.new('/')
  response = http.request(request)
  puts response.body
end

test_ssl_connection
