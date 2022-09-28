require "optparse"

# This class handles command-line arguments and light assertions.
#
# @attr_reader [Array<URI>] uris uris to request
class ArgvParser
  class Error < StandardError; end

  module Mode
    DOWNLOAD = :download # default
    METADATA = :metadata
    ARCHIVE = :archive
  end

  ALLOWED_SCHEMES = %w[http https].freeze

  attr_reader :uris

  # @param argv [Array<String>] command-line arguments
  def initialize(argv)
    argv = argv.dup # shadowed

    @parsed_config = { }
    
    opts = OptionParser.new
    opts.on("--metadata") do |_|
      raise Error, "--metadata cannot be specified with other mode flags" if @parsed_config.key?(:mode)
      @parsed_config[:mode] = Mode::METADATA
    end
    opts.on("--archive") do |_|
      raise Error, "--archive cannot be specified with other mode flags" if @parsed_config.key?(:mode)
      @parsed_config[:mode] = Mode::ARCHIVE
    end

    # treat non-options as urls
    urls = opts.parse!(argv)

    # the default mode is download
    @parsed_config[:mode] ||= Mode::DOWNLOAD

    @uris = urls.map do |url|
      # check the validness of the url roughly
      uri = URI.parse(url)
      raise Error, "#{url} is not a valid http/https URI" unless ALLOWED_SCHEMES.include?(uri.scheme)
      uri
    end
  end

  # @return [Symbol] see ArgvParser::Mode
  def mode
    @parsed_config[:mode]
  end
end