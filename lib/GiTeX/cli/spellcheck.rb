require 'thor'
require 'gitex'

module GiTeX
  class SpellCheckCommand < Thor

    desc 'document [OPTIONS]', 'Spell check the entire document'

    def document
      require 'gitex/cli/spellcheck/document'
      Document.new(options).run
    end
  end
end
