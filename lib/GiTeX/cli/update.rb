require 'thor'
require 'gitex'

module GiTeX
  class UpdateCommand < Thor

    desc 'cover IDENTIFIER [OPTIONS]', 'Update document cover with specified cover template'

    def cover identifier
      require 'gitex/cli/update/cover'
      Cover.new(options, identifier).run
    end
  end
end
