#!/usr/bin/ruby
# encoding: utf-8
require 'yaml'
require "rubygems" 
gem "hunspell"     
require "hunspell"



# Global variables
@sp = Hunspell.new("/Library/Spelling/pt_PT.aff", "/Library/Spelling/pt_PT.dic") 
@sp_en = Hunspell.new("/Library/Spelling/en_US.aff", "/Library/Spelling/en_US.dic") 
main = Hash.new
project_folder = ARGV[0].to_s

###


# File structure script

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


addFileToStructure(project_folder, main)

###

# Correction script

def correctoEnglishWord word, file
  if /^`.*'$/.match(word).to_s == ""
    puts "------------"
    puts "> File: #{file}"
    puts "> Error detected: \"#{word}\". English word dectected outside quote. Chose an option: [1] Quote word; [9] Edit file; [0] Ignore;"
    option = STDIN.gets.chomp.to_i
    if option == 1
      text = File.read(file)
      text = text.gsub(/ #{word} /, " `#{word}' ") # Palavras em inglês têm de ter sempre espaços à volta
      File.open(file, "w") {|file| file.puts text}
    elsif option == 9
      system "vim #{file}"
    end
  end
  puts "\n"
end

def correctoUnknownWord word, file
  puts "------------"
  puts "> File: #{file}"
  puts "> Error detected: \"#{word}\". This word does not seem to exist. Chose an option: [1] Replace word; [9] Edit file; [0] Ignore;"
  puts "Similiar words: #{@sp.suggest(word.encode("iso-8859-1").force_encoding("utf-8")).join(", ")}"
  print "Option: "  
  option = STDIN.gets.chomp.to_i
  if option == 1
    print "\nReplacement word: "  
    replace = STDIN.gets.chomp.encode("iso-8859-1").force_encoding("utf-8").to_s
    text = File.read(file)
    text = text.gsub(/#{word}/, "#{replace.encode("iso-8859-1").force_encoding("utf-8")}") # Acentos escaxam, usar palavras complexas senão pode substituir palavras a meio
    File.open(file,"w") {|file| file.puts text}
  elsif option == 9
    system "vim #{file}"
  end
  puts "\n"
end

def correctText text,file
  text.each do |word| # Não funciona para #emph e coisas do género
    if /^`.*'$/.match(word).to_s != "" && @sp_en.spellcheck(word[1...-1].encode("iso-8859-1").force_encoding("utf-8"))
    elsif @sp.spellcheck(word.encode("iso-8859-1").force_encoding("utf-8"))
    elsif @sp_en.spellcheck(word.encode("iso-8859-1").force_encoding("utf-8"))
      correctoEnglishWord word, file
    else
      correctoUnknownWord word, file
    end
  end
end

def extractText file
  text = [] 
  File.open(file, :encoding => "UTF-8").readlines.each do |line|
    if /^\\.*/.match(line).to_s == ""
      text += line.split(' ')
    elsif /^\\begin|end.*/.match(line).to_s == ""
      text += /\{(.*?)\}/.match(line).to_s[1...-1].split(' ')
    end
  end
  correctText text, file
end

def automaticCorrection hash
  puts "Starting spelling check!"
  hash.each do |key, value|
    extractText value["path"]
    if value["sections"]
      automaticCorrection value["sections"]
    end
  end
end


automaticCorrection main

