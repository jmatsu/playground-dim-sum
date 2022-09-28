# @attr_reader [Array<URI>] uris uris to request
class ArgvParser
  class Error < StandardError; end

  ALLOWED_SCHEMES = %w[http https].freeze

  attr_reader :uris

  def initialize(argv)
    argv = argv.dup # shadowed

    @uris = argv.map do |url|
      # check the validness of the url roughly
      uri = URI.parse(url)
      raise Error, "#{url} is not a valid http/https URI" unless ALLOWED_SCHEMES.include?(uri.scheme)
      uri
    end
  end
end