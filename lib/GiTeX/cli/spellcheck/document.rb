# encoding: utf-8

require 'yaml'
require 'git'
require 'gitex/helpers/directory'
require "hunspell"

include GiTeX::Helpers

module GiTeX
  class SpellCheckCommand::Document
    def initialize(options)
      @options = options
      git_dir = `git rev-parse --git-dir`
      @repository = Git.open("#{git_dir}/..")
      @repo_dir = @repository.dir.to_s
      @working_dir = Dir.pwd
      @sections = {}
      @structure = Hash.new
      @sp = Hunspell.new("/Library/Spelling/pt_PT2.aff", "/Library/Spelling/pt_PT2.dic") 
      @sp_en = Hunspell.new("/Library/Spelling/en_US.aff", "/Library/Spelling/en_US.dic") 
    end

    def run
      current_dir = "#{@repo_dir}/sections"

      read_document_structure(current_dir, @structure, @sections)
      # add_introduction_and_resume_to_sections
      puts "---- Starting spelling check!----\n"
      automatic_correction @sections
    end

    private

    def automatic_correction sections
      sections.each do |id, section| 
        extract_text section[:path]
        if section[:sections]
          automatic_correction section[:sections]
        end
      end
    end

    def extract_text file
      text = [] 
      File.open(file, :encoding => "UTF-8").readlines.each do |line|
        if /^{.*/.match(line).to_s != ""
        elsif /^\\.*/.match(line).to_s == ""
          text += line.split(' ')
        elsif /^\\begin|end|bash|input|label|END.*/.match(line).to_s == ""
          text += /\s*\{(.*?)\}/.match(line).to_s[1...-1].split(' ')
        end
      end
      correct_text text, file
    end

    def correct_text text, file
      text.each do |word| 
        if /^\\.*/.match(word).to_s != ""
          next
        end
        word = word.gsub(/!|,|;|\?|\./, '')
        if @sp.spellcheck(word.force_encoding("utf-8"))
        elsif @sp_en.spellcheck(word.force_encoding("utf-8"))
          correct_english_word word, file
        else
          correct_unknown_word word, file
        end
      end
    end

    def correct_unknown_word word, file
      puts "------------"
      puts "> File: #{file}"
      puts "> Error detected: \"#{word}\". This word does not seem to exist. Chose an option: [1] Replace word; [9] Edit file; [0] Ignore;"
      puts "Similiar words: #{@sp.suggest(word.force_encoding("utf-8")).join(", ")}"
      print "Option: "  
      option = STDIN.gets.chomp.to_i
      if option == 1
        print "\nReplacement word: "  
        replace = STDIN.gets.chomp.to_s
        text = File.read(file).force_encoding("utf-8")
        text = text.gsub(/#{word}/, "#{replace.force_encoding("utf-8")}") # Usar palavras complexas senão pode substituir palavras a meio
        File.open(file,"w") {|file| file.puts text}
      elsif option == 9
        system "vim #{file}"
      end
      puts "\n"
    end

    def correct_english_word word, file
      if /^`.*'$/.match(word).to_s == ""
        puts "------------"
        puts "> File: #{file}"
        puts "> Error detected: \"#{word}\". English word dectected outside quote. Chose an option: [1] Quote word; [9] Edit file; [0] Ignore;"
        print "Option: " 
        option = STDIN.gets.chomp.to_i
        if option == 1
          text = File.read(file).force_encoding("utf-8")
          text = text.gsub(/#{word}/, "\\emph{#{word}}") # Palavras em inglês têm de ter sempre espaços à volta
          File.open(file, "w") {|file| file.puts text}
        elsif option == 9
          system "vim #{file}"
        end
      end
      puts "\n"
    end

    def read_document_structure(current_dir, structure, sections)
      Dir.chdir(current_dir)
      tex_files = Dir.glob("*.tex")

      tex_files.each do |tex_file|
        section = {}
        section_path = "#{Dir.pwd}/#{tex_file}"

        section[:title] = section_title section_path
        section[:path] = section_path

        section_match = /^(?<section_position>\d+)_(?<section_id>[^_\s]*)_/.match(tex_file)

        if section_match
          section_id = section_match[:section_id]
          section_position = section_match[:section_position]

          if section_id.empty? || section_position.empty?
            section_id = SecureRandom.hex(3)
            section_position = "999"
          end     
        else      
          section_id = SecureRandom.hex(3)
          section_position = "999"     
        end
        
        section[:id] = section_id 
        section[:position] = section_position

        sections[section_id] = section
        structure[section_id] = section

        section_folder = tex_file[/^(?<section_folder>.*).tex/, "section_folder"]
        if Dir.exists?(section_folder)
          section[:sections] = Hash.new
          read_document_structure(section_folder, section[:sections], sections)
          Dir.chdir("../")
        end
      end
    end

    def section_title path
      content = File.open(path, :encoding => "UTF-8").readlines.first
      content[/section\{(?<title>.*)\}/, "title"] || "Untitled"
    end

  end
end
