require 'nokogiri'

class MetadataReader
  # @param file [File] an opened file. this class does not close it so be careful.
  def initialize(file)
    @html = Nokogiri::HTML(file)
    @site = File.basename(file.path.gsub(/\.html\z/, ''))
    @last_fetch = file.mtime
  end

  # @return [Hash] a metadata of a content
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