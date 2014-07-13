require 'gitex/meta'

module GiTeX::Helpers
  class Directory::Library
    def self.path
      t = ["#{File.dirname(File.expand_path($0))}/../lib/#{GiTeX::Meta::NAME}",
           "#{Gem.dir}/gems/#{GiTeX::Meta::NAME}-#{GiTeX::Meta::VERSION}/lib/#{GiTeX::Meta::NAME}"]
      t.each {|i| return i if File.readable?(i) }
      raise "both paths are invalid: #{t}"
    end
  end
end
