require 'fileutils'
require 'tempfile'
require 'uri'

# File Reader/Writer class.
#
# @attr_reader [String] html_content_path a path of a HTML file
class FileSystem
  class Error < StandardError; end
  class FileNotFoundError < Error
    def initialize(path:)
      super("#{path} is not found")
    end
  end

  attr_reader :html_content_path

  # @param uri [URI] incoming URI
  def initialize(uri:)
    raise 'nil is not allowed for uri' if uri.nil?
    *@dirs, @filepart = split_path_segments(uri: uri)
    @html_content_path = File.join(*@dirs, "#{@filepart}.html")
  end

  def archive_dir_path
    "#{@html_content_path}.d"
  end

  # @param content [String] the content to save as html
  # @return [void]
  def save_html(content:)
    FileUtils.mkdir_p(File.join(@dirs)) unless @dirs.empty?

    Tempfile.open('content') do |f|
        f.write(content)

        # for now, thi script overwrites the output anyway
        FileUtils.mv(f.path, @html_content_path)
    end
  end

  # @param content [String] the content to save
  # @param path [String] a path to save
  # @return [void]
  def save_in_archive(content:, path:)
    raise "#{path} does not contain #{archive_dir_path}" unless path.start_with?(archive_dir_path)

    FileUtils.mkdir_p(archive_dir_path)

    Tempfile.open('content') do |f|
        f.write(content)

        # for now, thi script overwrites the output anyway
        FileUtils.mv(f.path, path)
    end
  end

  # proxy for File#open
  def open_html(&block)
    raise FileNotFoundError.new(path: html_content_path) unless File.exist?(html_content_path)

    if block_given?
      File.open(html_content_path, &block)
    else
      File.open(html_content_path)
    end
  end

  private def split_path_segments(uri:)
    paths = uri.path.split("/").reject(&:empty?)
  
    if uri.port == 443 || uri.port == 80
      [uri.host, *paths]
    else
      ["#{uri.host}:#{uri.port}", *paths]
    end
  end
end