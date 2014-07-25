require 'thor'
require 'git'
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
    method_option :authors,
                  type:    :string,
                  aliases: '-a',
                  banner:  'Specify the project authors'
    method_option :date,
                  type:    :string,
                  aliases: '-d',
                  banner:  'Specify the project date'

    def init title
      require 'gitex/cli/init'
      Init.new(options, title).run
    end

    desc 'generate FORMAT [OPTIONS]', 'Generate a document of specified format from LaTeX source'

    def generate format
      require 'gitex/cli/generate'
      Generate.new(options, format).run
    end

    desc 'print structure [OPTIONS]', 'Generate a document of specified format from LaTeX source'

    def print structure
      git_dir = `git rev-parse --git-dir`
      @repository = Git.open("#{git_dir}/..")
      @repo_dir = @repository.dir.to_s
      puts "Document structure"
      puts "------------------"
      puts "Cover"
      puts "Abstract"
      puts "Table of Contents"
      File.open(@repo_dir+"/.structure.tmp", :encoding => "UTF-8").readlines.each do |line|
        puts line
      end
      puts "Bibliography"
    end

    desc 'spellcheck PART [OPTIONS]', 'Spell check the document or a section'

    require 'gitex/cli/spellcheck'
    subcommand "spellcheck", SpellCheckCommand
    desc "include TYPE [OPTIONS]", "Include new elements in document"


    require 'gitex/cli/include'
    subcommand "include", IncludeCommand

    desc "update PART [OPTIONS]", "Update a document part"

    require 'gitex/cli/update'
    subcommand "update", UpdateCommand

  end
end
