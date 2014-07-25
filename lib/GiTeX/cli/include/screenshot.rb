require 'git'
require 'gitex/helpers/directory'
require 'uri'
require 'open-uri'
require 'fileutils'
require 'pathname'


include GiTeX::Helpers

module GiTeX
  class IncludeCommand::Screenshot
    def initialize(options,paramaters)
      @options = options
      @paramaters = paramaters
    end

    def run
      generate_image
    end

    private

    def generate_image
      take_screenshot

    end
    def take_screenshot
      FileUtils::mkdir_p 'images/screenshots'
      driver = Selenium::WebDriver.for :firefox
      @paramaters.each do |url|
        driver.navigate.to url
        host = Addressable::URI.parse(url).host
        driver.save_screenshot("images/screenshots/#{host}.jpg")

      end
      driver.quit
    end
  end
end
