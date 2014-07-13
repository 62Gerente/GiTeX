module GiTeX::Helpers
  class Directory
    def self.library
      "#{File.dirname(__FILE__)}/.."
    end

    def self.templates
      "#{library}/templates"
    end
  end
end
