#!/usr/bin/ruby
# encoding: utf-8
require 'yaml'


# Global variables

main = Hash.new
project_folder = ARGV[0].to_s

###

# functions


def getTitle file
  a = File.open(file, :encoding => "UTF-8").readlines.first
  /\{(.*?)\}/.match(a).to_s[1...-1]
end

def addFileToStructure folder, main
  Dir.chdir(folder)
  a = Dir.glob("*.tex")
  a.each do |e|
    doc_section =  Hash.new
    doc_section["title"] = getTitle(Dir.pwd + "/" + e)
    doc_section["path"] = Dir.pwd + "/" + e
    main[ /^\d+/.match(e).to_s] = doc_section
    recursive_folder = /[^.]*/.match(e).to_s
    if Dir.exists?(recursive_folder)
      doc_section["sections"] = Hash.new
      addFileToStructure(recursive_folder, doc_section["sections"])
      Dir.chdir("../")
    end
  end
end

###

# Script

addFileToStructure(project_folder, main)
puts main.to_yaml

###


