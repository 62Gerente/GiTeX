require 'thor'
require 'gitex'

module GiTeX
  class CLI < Thor

    desc 'init "DOCUMENT TITLE" [OPTIONS]', 'Create an latex document and initialize an git repository'

    method_option :repository,
                  type:    :string,
                  aliases: '-r',
                  banner:  'Specify the git repository name'
    method_option :class,
                  type:    :string,
                  aliases: '-c',
                  banner:  'Specify the document class'   
    method_option :template,
                  type:    :string,
                  aliases: '-t',
                  banner:  'Specify the document template'      
    method_option :cover,
                  type:    :string,
                  aliases: '-t',
                  banner:  'Specify the document template'  
    method_option :folder,
                  type:    :string,
                  aliases: '-f',
                  banner:  'Specify the project folder name'    

    def init document_title
      require 'gitex/cli/init'
      Init.new(options, document_title).run
    end
  end
end
