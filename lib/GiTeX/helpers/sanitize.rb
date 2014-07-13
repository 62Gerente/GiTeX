module GiTeX::Helpers
  class Sanitize
    def self.filename filename
      require 'gitex/helpers/sanitize/filename'
      Filename.new(filename).sanitize
    end
  end
end
