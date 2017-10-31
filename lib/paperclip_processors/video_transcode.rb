module Paperclip
  class VideoTranscode < Processor

    attr_accessor :geometry, :whiny

    def initialize(file, options = {}, attachment = nil)
      super
      unless options[:geometry].nil? || (@geometry = Geometry.parse(options[:geometry])).nil?
        @geometry.width = (@geometry.width / 2.0).floor * 2.0
        @geometry.height = (@geometry.height / 2.0).floor * 2.0
        @geometry.modifier = ''
      end
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @basename = File.basename(file.path, File.extname(file.path))
    end

    def make
      dst = Tempfile.new([ @basename, 'flv' ].compact.join("."))
      dst.binmode

      cmd = %Q[-i "#{File.expand_path(file.path)}" -y -f flv -vcodec flv -b 512000 -r 30 -acodec libmp3lame -ab 32 -ar 22050 ]
      cmd << "-s #{geometry.to_s} " unless geometry.nil?
      cmd << %Q["#{File.expand_path(dst.path)}"]

      begin
        success = Paperclip.run('ffmpeg', cmd)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error transcoding #{@basename}" if whiny
      end

      app = 'flvtool2'
      app << '.exe' if RUBY_PLATFORM =~ /mswin/
      cmd = %Q[-U "#{File.expand_path(dst.path)}" ]
      
      puts '--------------'
      puts app
      puts cmd
      puts '--------------'

      begin
        success = Paperclip.run(app, cmd)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error updating FLV metadata for #{@basename}" if whiny
      end

      dst
    end
  end
end
