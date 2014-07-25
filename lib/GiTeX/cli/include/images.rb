require 'git'
require 'gitex/helpers/directory'
require 'uri'
require 'open-uri'
require 'fileutils'
require 'pathname'
require 'enumerator'



include GiTeX::Helpers

module GiTeX
  class IncludeCommand::Images
    def initialize(options,paramaters)
      @options = options
      @paramaters = paramaters
      @images = []
    end

    def run
      usepackage
      calculate_col_size
      generate_image
    end

    private
    def calculate_col_size
      @colSize = 1.0
      if @options["columns"]
        @col_size = 1 / @options["columns"].to_f
        @col_size = "%.1f" % @col_size
      end
    end

    def generate_image
      images = get_images
      images = images.each_slice(@options["columns"]||1).to_a

      FileUtils::mkdir_p 'images'
      images.each_with_index do |arg,i|
        figure{
          centering
          arg.each_with_index do |arg_name,j|
            if File.file?(arg_name)
              subfigure(@col_size){
                path = Pathname.new(arg_name).realpath.to_s
                image_path = Pathname.new("images").realpath.to_s
                if path =~ /^#{image_path}/
                  arg = path.to_s
                else
                  arg = copy path , image_path
                end
                includegraphics(arg.to_s)
                label("#{i}_#{j}")
              }
            end
          end
        }
      end
    end

    def get_images
      images = []
      @paramaters.each do |arg|
        Dir.foreach(arg) do |item|
          next if item == '.' or item == '..' or item == '.DS_Store' or item == '.localized'
          images << "#{arg}/#{item}"
        end
      end
      images
    end

    def copy src,dst
      basename = Pathname.new(src).basename
      FileUtils.cp(src,"#{dst}/#{basename}")
      "images/#{basename}"
    end
    def usepackage
      "\\usepackage{graphicx}"
      "\\usepackage{caption}"
      "\\usepackage{subcaption}"
    end

    def subfigure(size)
      puts "\\begin{subfigure}[b]{#{size}\\textwidth}"
      yield
      puts "\\end{subfigure}"
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

  end
end
