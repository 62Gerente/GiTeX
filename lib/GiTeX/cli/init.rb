require 'git'

require 'gitex/helpers/sanitize'
require 'gitex/helpers/directory'

include GiTeX::Helpers

module GiTeX
  class CLI::Init
    attr_reader :options

    def initialize(options, title)
      @title = title
      @author = options[:author] ? options[:author] : ''
      @date = options[:date] ? options[:date] : '\today'
      @class = options[:class] ? options[:class] : 'article'
      @template = options[:template] ? options[:template] : 'main'
      @folder = options[:folder] ? options[:folder] : Sanitize.filename(@title)
    end

    def run
      init_git_repository
      add_gitignore
      add_template
    end

    private

    def init_git_repository
      @repository = Git.init(@folder)
      @repo_dir = @repository.dir.to_s
    end

    def add_gitignore
      FileUtils.cp("#{Directory.templates}/gitignores/TEX.gitignore", "#{@repo_dir}/.gitignore")
    end

    def add_template
      FileUtils.cp_r(Dir["#{Directory.templates}/#{@template}/*"], @repo_dir)
      FileUtils.mkdir_p("#{@repo_dir}/sections") unless File.exists?("#{@repo_dir}/sections")
      main = "#{@repo_dir}/main.tex"

      content = File.read(main)

      content = content.gsub(/## CLASS ##/, @class)   || content
      content = content.gsub(/## TITLE ##/, @title)   || content
      content = content.gsub(/## AUTHOR ##/, @author) || content
      content = content.gsub(/## DATE ##/, @date)     || content

      File.open("#{@repo_dir}/main.tex", "w") {|file| file.puts content}
    end
  end
end
