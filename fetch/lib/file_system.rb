require 'fileutils'
require 'tempfile'
require 'uri'

# @attr_reader [String] content_path a path of a content file
class FileSystem
  class Error < StandardError; end
  class FileNotFoundError < Error
    def initialize(path:)
      super("#{path} is not found")
    end
  end

  attr_reader :content_path

  # @param uri [URI] incoming URI
  def initialize(uri:)
    raise 'nil is not allowed for uri' if uri.nil?
    *@dirs, @filepart = split_path_segments(uri: uri)
    @content_path = File.join(*@dirs, "#{@filepart}.html")
  end

  # @param context [String] the content to save
  # @return [void]
  def save(content:)
    FileUtils.mkdir_p(*@dirs) unless @dirs.empty?

    Tempfile.open(['content', '.html']) do |f|
        f.write(content)

        # for now, thi script overwrites the output anyway
        FileUtils.mv(f.path, @content_path)
    end
  end

  # proxy for File#open
  def open(&block)
    raise FileNotFoundError.new(path: content_path) unless File.exist?(content_path)

    if block_given?
      File.open(content_path, &block)
    else
      File.open(content_path)
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