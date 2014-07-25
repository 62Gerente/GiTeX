require 'git'

module GiTeX
  class CLI::Generate
    attr_reader :options

    def initialize(options, format)
      @format = format.downcase
      git_dir = `git rev-parse --git-dir`
      @repository = Git.open("#{git_dir}/..")
      @repo_dir = @repository.dir.to_s
      @working_dir = Dir.pwd
    end

    def run
      generate_document
    end

    private

    def generate_document
      case @format
      when "pdf"
        run_pdflatex
      when "html"
        run_htlatex
      end
    end

    def run_pdflatex
      system "cd #{@repo_dir}"
      system "pdflatex -shell-escape #{@repo_dir}/main"
      system "bibtex #{@repo_dir}/main"
      system "pdflatex -shell-escape #{@repo_dir}/main"
      system "pdflatex -shell-escape #{@repo_dir}/main"
      clean_pdflatex_aux_files
      system "cd #{@working_dir}"
    end

    def run_htlatex
      system "cd #{@repo_dir}"
      system "htlatex #{@repo_dir}/main"
      system "bibtex #{@repo_dir}/main"
      system "htlatex #{@repo_dir}/main"
      clean_htlatex_aux_files
      system "cd #{@working_dir}"
    end

    def clean_pdflatex_aux_files
      system "rm *.lof *.lot *.out *.toc *.aux *.log *.bbl *.bgl *.stderr *.sh"
    end

    def clean_htlatex_aux_files
      system "rm *.4tc *.4ct *.aux *.dvi *.idv *.lg *.log *.bbl *.blg *.tmp"
    end
  end
end
