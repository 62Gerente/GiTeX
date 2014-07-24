require 'git'
require 'gitex/helpers/directory'
require 'gitex/helpers/sanitize'
require 'yaml'
require 'fileutils'
require 'securerandom'

include GiTeX::Helpers

module GiTeX
  class UpdateCommand::Cover
    def initialize(options)
      git_dir = `git rev-parse --git-dir`
      @repository = Git.open("#{git_dir}/..")
      @repo_dir = @repository.dir.to_s
      @working_dir = Dir.pwd
      @sections = {}
      @structure = []
    end

    def run
      current_dir = "#{@repo_dir}/sections"

      read_document_structure(current_dir, @structure, @sections)
      write_document_structure_to_temp_file
      open_structure_with_default_text_editor
      update_report_structure
    end

    private

    def update_report_structure
      structure_temp_file = "#{@repo_dir}/.structure.tmp"
      lines = File.open(structure_temp_file, :encoding => "UTF-8").readlines
      
      current_identation = ""
      current_path = "#{@repo_dir}/sections"
      partial_path = "sections"
      current_identifier = ""
      default_identation = 0

      levels = [1, 1 ,1]
      current_level = 0

      lines.each do |line|
        line_match = /^(?<indentation>\s*)((?<section_id>\S*)\s*#)?\s*(?<title>.*)/.match(line)

        indentation      = line_match[:indentation]
        section_id       = line_match[:section_id]       || SecureRandom.hex(3)
        title            = line_match[:title]            || "Untitled"

        filename = Sanitize.filename(title)

        default_identation = indentation.length - current_identation.length if default_identation <= 0

        if indentation.length > current_identation.length
          current_path << "/#{current_identifier}"
          partial_path << "/#{current_identifier}"
          FileUtils::mkdir_p current_path
          current_level += 1
        elsif indentation.length < current_identation.length
          current_path << "/.."*((current_identation.length - indentation.length)/default_identation)
          partial_path << "/.."*((current_identation.length - indentation.length)/default_identation)
          current_level -= 1
        end

        identifier = "#{'%03d' % (levels[current_level]*10)}_#{section_id}_#{filename}" 
        new_section_path = "#{current_path}/#{identifier}.tex"
        new_partial_path = "#{partial_path}/#{identifier}"

        if(@sections.key? section_id)
          section = @sections[section_id]
          system("mv \"#{section[:path]}\" \"#{new_section_path}\"")
        else
          FileUtils.touch(new_section_path)
        end

        content = File.read(new_section_path)

        if content =~ /^.*\\(sub)*section\{.*\}.*(\n\\label.*)?/
          content = content.gsub(/^.*\\(sub)*section\{.*\}.*(\n\\label.*)?/, "\\#{section_tag current_level}{#{title}}\n\\label{sec:#{filename}}\n")
        else
          content = "\\#{section_tag current_level}{#{title}}\n\\label{sec:#{filename}}\n" + content
        end

        if content =~ /^.*\\bash(.|\n)*\\END\s*\\input\{.*\}/
          content = content.gsub(/^.*\\bash(.|\n)*\\END\s*\\input\{.*\}/, '\bash[stdoutFile=' + new_partial_path + '_sections]' + "\n" + '{ shopt -s nullglob; for file in ' + new_partial_path + '/*.tex; do echo "\\input{$file}"; done; } ' + "\n" + '\END' + "\n" + '\input{' + new_partial_path + '_sections}')
        else
          content = content + "\n\n\n\n\n\n\n\n" + '\bash[stdoutFile=' + new_partial_path + '_sections]' + "\n" + '{ shopt -s nullglob; for file in ' + new_partial_path + '/*.tex; do echo "\\input{$file}"; done; } ' + "\n" + '\END' + "\n" + '\input{' + new_partial_path + '_sections}'
        end     

        File.open(new_section_path, "w") {|file| file.puts content}

        levels[current_level] += 1
        current_identifier = identifier
        current_identation = indentation
      end
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
        structure << section

        section_folder = tex_file[/^(?<section_folder>.*).tex/, "section_folder"]
        if Dir.exists?(section_folder)
          section[:sections] = []
          read_document_structure(section_folder, section[:sections], sections)
          Dir.chdir("../")
        end
      end
    end

    def write_document_structure_to_temp_file
      File.open("#{@repo_dir}/.structure.tmp", "w") do |file| 
        indentation = ""

        write_sections file, @structure
      end
    end

    def write_sections file, structure, indentation=""
      structure.sort_by{|s| s[:position]}.each do |section|
        file.puts "#{indentation}#{section[:id]}# #{section[:title]}"

        write_sections file, section[:sections], "#{indentation}    " if section[:sections]
      end
    end

    def open_structure_with_default_text_editor
      structure_temp_file = "#{@repo_dir}/.structure.tmp"
      system("\"${EDITOR:-vi}\" #{structure_temp_file}")
    end

    def section_title path
      content = File.read(path)
      content[/section\{(?<title>.*)\}/, "title"] || "Untitled"
    end

    def section_tag level
      case level
      when 0
        "section"
      when 1
        "subsection"
      else
        "subsubsection"
      end
    end
  end
end
