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
      puts "wwoooww"
    end
  end
end
