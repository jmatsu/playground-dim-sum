require 'nokogiri'
require 'securerandom'

class Archiver
  # TODO: need to look up background-images of CSS and others.
  ASSET_MAPPING_FOR_ACHIVE = [
    {
      xpath: '//img',
      ref: 'src'
    },
    {
      xpath: '//script',
      ref: 'src'
    },
    {
      xpath: '//link',
      ref: 'href'
    }
  ].freeze

  # @param file [File] an opened file. this class does not close it so be careful.
  def initialize(file)
    @html = Nokogiri::HTML(file)
  end

  # BE CAREFUL: this code does not take care of path traversal
  # @return [Array<[URI, String]>] a list of pairs that consist of remote URIs and local file paths
  # @yeildparam [String] the modified HTML content
  def modify_assets!(local_prefix:, remote_prefix:)
    raise 'block is required' unless block_given?

    uris = []
    
    ASSET_MAPPING_FOR_ACHIVE.each do |m|
      @html.search(m[:xpath]).each do |dom|
        remote_path = dom.attr(m[:ref])

        # We need to archive only relative references
        next if remote_path.nil? || remote_path.empty? || !remote_path.start_with?("/")

        if remote_path.start_with?("//")
          # complete the scheme
          dom[m[:ref]] = "#{URI.parse(remote_prefix).scheme}://#{remote_path}"
        else
          # complete the scheme, host, port
          # TODO: naked domain doesn't work?
          remote_uri = URI.parse(remote_prefix + remote_path)

          # we do not need to keep the URLs perfectly because of DOM manipulation.
          # TODO: 20 is experimental
          local_path = local_prefix + "/" + SecureRandom.hex(20) + File.extname(remote_uri.path)
          
          # modify remote relative links into local absolete links
          dom[m[:ref]] = local_path

          uris.push([remote_uri, local_path])
        end
      end
    end

    yield(@html.to_html)

    uris
  end
end

