require 'net/http'

class HttpClient
  class Error < StandardError; end

  MAX_ATTEMPT_COUNT = 3.freeze # experimental

  # @param uri [URI] a URI to request
  # @param attempt_count [Integer] how many times this client has tried
  # @return [String] the content
  # @raise [Error] any error happened in the request chain
  def get(uri:, attempt_count: 0)
    raise Error, "attempt count limit exceeded." if attempt_count >= MAX_ATTEMPT_COUNT

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end

    case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        get(uri: URI.parse(response['location']), attempt_count: attempt_count + 1)
      else
        # We assume this case is a failure anyway
        raise Error, "the request failed due to #{response.code} #{response.message}"
    end
  rescue URI::Error
    raise Error, 'cannot request to an invalid uri'
  end
end