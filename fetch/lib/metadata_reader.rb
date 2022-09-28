require 'nokogiri'

# Collects metadata from file stats and their contents
class MetadataReader
  # @param file [File] an opened file. this class does not close it so be careful.
  def initialize(file)
    @html = Nokogiri::HTML(file)
    @site = file.path.gsub(/\.html\z/, '')[Dir.pwd.length..] # trust the naming convention
    @last_fetch = file.mtime
  end

  # @return [Hash] a metadata of a content
  #    site: [String] URL
  #    num_links: the number of a tags which have href attributes. They may contain invalid/expired links.
  #    images: the number of img tags which have src attributes. They may contain invalid/expired links.
  #    last_fetch: when the file was fetched. No modification by other than this script is expected
  def read
    images = @html.search('//img').reject { |d| d.attr('src')&.empty? }.count
    num_links = @html.search('//a').reject { |d| d.attr('href')&.empty? }.count

    {
      site: @site,
      num_links: num_links,
      images: images,
      last_fetch: @last_fetch
    }
  end
end