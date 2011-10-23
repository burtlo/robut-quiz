require './lib/robut_quiz'

class Robut::Plugin::Quiz
  def self.show_version_changes(version)
    date = ""
    changes = []  
    grab_changes = false

    File.open("#{File.dirname(__FILE__)}/History.txt",'r') do |file|
      while (line = file.gets) do

        if line =~ /^===\s*#{version.gsub('.','\.')}\s*\/\s*(.+)\s*$/
          grab_changes = true
          date = $1.strip
        elsif line =~ /^===\s*.+$/
          grab_changes = false
        elsif grab_changes
          changes = changes << line
        end

      end
    end

    { :date => date, :changes => changes }
  end
end

Gem::Specification.new do |s|
  s.name        = 'robut-quiz'
  s.version     = ::Robut::Plugin::Quiz::VERSION
  s.authors     = ["Franklin Webber"]
  s.description = %{ Robut plugin that provides quiz asking functionality. }
  s.summary     = "Quiz asking Robut"
  s.email       = 'franklin.webber@gmail.com'
  s.homepage    = "http://github.com/burtlo/robut-quiz"

  s.platform    = Gem::Platform::RUBY
  
  changes = Robut::Plugin::Quiz.show_version_changes(::Robut::Plugin::Quiz::VERSION)
  
  s.post_install_message = "
--------------------------------------------------------------------------------
    ___
  !(O-0)! ~ Thank you for installing robut-quiz #{::Robut::Plugin::Quiz::VERSION} / #{changes[:date]}
 >==[ ]==<
    @ @

  Changes:
  #{changes[:changes].collect{|change| "  #{change}"}.join("")}
--------------------------------------------------------------------------------"

  s.add_dependency 'robut', '~> 0.3'
  
  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.extra_rdoc_files = ["README.md", "History.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
