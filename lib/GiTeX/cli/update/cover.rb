require 'git'

module GiTeX
  class UpdateCommand::Cover
    attr_reader :options

    def initialize(options, identifier)
      @identifier = identifier.downcase
      git_dir = `git rev-parse --git-dir`
      @repository = Git.open("#{git_dir}/..")
      @repo_dir = @repository.dir.to_s
      @working_dir = Dir.pwd
    end

    def run
      update_cover
    end

    private

    def update_cover
      move_cover

      case @identifier
      when "university"
        university_cover 
      end
    end

    def move_cover
      FileUtils.cp(Dir["#{Directory.templates}/covers/#{@identifier}.tex"], "#{@repo_dir}/cover.tex")
    end

    def university_cover
      cover = "#{@repo_dir}/cover.tex"
      
      institution = options[:institution] ? options[:institution] : ''
      major = options[:major] ? options[:major] : ''
      minor = options[:minor] ? options[:minor] : ''
      supervisor = options[:supervisor] ? options[:supervisor] : ''

      content = File.read(cover)

      content = content.gsub(/## INSTITUTION ##/, institution) || content
      content = content.gsub(/## MAJOR ##/, major)             || content
      content = content.gsub(/## MINOR ##/, minor)             || content
      content = content.gsub(/## DATE ##/, @date)              || content
      content = content.gsub(/## TITLE ##/, @title)            || content
      content = content.gsub(/## AUTHOR ##/, @author)          || content
      content = content.gsub(/## SUPERVISOR ##/, supervisor)   || content

      File.open("#{@repo_dir}/cover.tex", "w") {|file| file.puts content}
    end
  end
end
