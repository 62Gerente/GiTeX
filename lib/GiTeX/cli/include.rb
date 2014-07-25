require 'thor'
require 'gitex'

module GiTeX
  class IncludeCommand < Thor

    desc 'image', 'Generate latex image code from path or url'

    def image(*paramaters)
      require 'gitex/cli/include/image'
      IncludeCommand::Image.new(options,paramaters).run
    end

    desc 'images', 'Generate latex image code from folder with image inside'

    method_option :columns,
      type:    :numeric,
      aliases: '-c'

    def images(*paramaters)
      require 'gitex/cli/include/images'
      IncludeCommand::Images.new(options,paramaters).run
    end

    desc 'screenshots', 'Generate latex image code from screenshots of url'

    def screenshots(*paramaters)
      require 'gitex/cli/include/screenshots'
      IncludeCommand::Screenshots.new(options,paramaters).run
    end

  end
end
