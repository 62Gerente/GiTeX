require 'thor'
require 'gitex'

module GiTeX
  class UpdateCommand < Thor

    desc 'cover IDENTIFIER [OPTIONS]', 'Update document cover with specified cover template'

    method_option :author,
                  type:    :string,
                  aliases: '-a',
                  banner:  'Specify the project author'  
    method_option :date,
                  type:    :string,
                  aliases: '-d',
                  banner:  'Specify the project date'  
    method_option :title,
                  type:    :string,
                  aliases: '-t',
                  banner:  'Specify the project title'  
    method_option :institution,
                  type:    :string,
                  aliases: '-i',
                  banner:  'Specify the project institution'  
    method_option :major,
                  type:    :string,
                  banner:  'Specify the project major'  
    method_option :minor,
                  type:    :string,
                  banner:  'Specify the project minor'  
    method_option :supervisor,
                  type:    :string,
                  aliases: '-s',
                  banner:  'Specify the project supervisor'  

    def cover identifier
      require 'gitex/cli/update/cover'
      Cover.new(options, identifier).run
    end

    desc "structure [OPTIONS]", "Open document structure for update"

    def structure
      require 'gitex/cli/update/structure'
      Cover.new(options).run
    end
  end
end
