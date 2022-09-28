require 'fileutils'
require 'tempfile'
require 'uri'

class FileWriter
  # @param uri [URI] incoming URI
  def initialize(uri:)
    @uri = uri or raise 'nil is not allowed for uri'
  end

  # @param context [String] the content to save
  # @return [String] a path to write
  def save(content:)
    *dirs, filepart = *split_path_segments(uri: @uri)

    save_to = File.join(*dirs, "#{filepart}.html")

    FileUtils.mkdir_p(*dirs) unless dirs.empty?

    Tempfile.open(['content', '.html']) do |f|
        f.write(content)

        # for now, thi script overwrites the output anyway
        FileUtils.mv(f.path, save_to)
    end

    save_to
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