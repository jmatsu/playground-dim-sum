require "optparse"

# @attr_reader [Array<URI>] uris uris to request
class ArgvParser
  class Error < StandardError; end

  ALLOWED_SCHEMES = %w[http https].freeze

  attr_reader :uris

  def initialize(argv)
    argv = argv.dup # shadowed

    @parsed_config = {}
    opts = OptionParser.new
    opts.on("--metadata") do |_|
      @parsed_config[:metadata_mode] = true
    end

    # treat non-options as urls
    urls = opts.parse!(argv)

    @uris = urls.map do |url|
      # check the validness of the url roughly
      uri = URI.parse(url)
      raise Error, "#{url} is not a valid http/https URI" unless ALLOWED_SCHEMES.include?(uri.scheme)
      uri
    end
  end

  # @return [Boolean] returns true if the current behavior is a metadata mode, otherwise false
  def metadata_mode?
    @parsed_config[:metadata_mode] == true
  end
end