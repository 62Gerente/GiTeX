require 'git'
require 'gitex/helpers/directory'
require 'uri'
require 'open-uri'
require 'fileutils'
require 'pathname'


include GiTeX::Helpers

module GiTeX
  class IncludeCommand::Image
    def initialize(options,paramaters)
      @options = options
      @paramaters = paramaters
    end

    def run
      generate_image
    end

    private

    def generate_image
      FileUtils::mkdir_p 'images'
      @paramaters.each_with_index do |arg,i|
        figure{
          centering
          if arg =~ URI::regexp
            imageName = getImage(arg)
            includegraphics(imageName)
          elsif File.file?(arg)
            path = Pathname.new(arg).realpath.to_s
            image_path = Pathname.new("images").realpath.to_s
            if path =~ /^#{image_path}/
              arg = path.to_s
            else
              arg = copy path , image_path
            end
            includegraphics(arg.to_s)
          end
          label(i)
        }
      end
    end

    def figure
      puts "\\begin{figure}[H]"
      yield
      puts "\\end{figure}"
    end

    def centering
      puts "\\centering"
    end

    def includegraphics(image)
      puts "\\includegraphics[width=\\textwidth]{#{image.gsub(/-/){|o| "\\#{o}"}}}"
    end

    def label(index)
      puts "\\label{fig:#{index}}"
    end

    def getImage(url)
      uri = URI.parse(url)
      fileName = File.basename(uri.path)
      open("images/#{fileName}", 'wb') do |file|
        file << open(uri).read
      end
      "images/#{fileName}"
    end

    def copy src,dst
      basename = Pathname.new(src).basename
      FileUtils.cp(src,"#{dst}/#{basename}")
      "images/#{basename}"
    end
  end
end
