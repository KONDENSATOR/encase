# Copyright (c) 2011 KONDENSATOR AB, Fredrik Andersson
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'yaml'
require 'etc'


def which(prg)
  %x{which #{prg}}.strip
end
def autoconf(to_file)
  File.open(to_file, 'w') do |f|  
    f.puts "sudo: #{which('sudo')}"
    f.puts "realgrowl: #{which('realgrowl')}"
    f.puts "git: #{which('git')}"
    f.puts "ruby: #{which('ruby')}"
    f.puts "env: #{which('env')}"
  end
end

#######################################################
# Load any setting files

@encase_config_file = '.encase'

def config_file(user_path)
  File.join(user_path, @encase_config_file)
end

def load_paths(from_file)
  result = {}
  yaml = YAML::load(File.open(from_file))
  yaml.each { |key, value|
    result[key] = value
  }
  result
end  

def load_config(user_path)
  yaml = YAML::load(File.open(config_file(user_path)))
  user_config = {}
  yaml.each { |folder, filters|
    folder = folder.sub('~', user_path)
    user_config[folder] = filters && filters.map { |filter|
      Regexp.new(filter, true)
    }
  }
  user_config
end

def load_settings
  settings = []
  # Read all users from password file
  while entry = Etc.getpwent()
    # If particular user has a ~/.encase file, then we need to read that information
    if File.exists? config_file(entry['dir'])
      # Create user object with data from Etc.getpwent
      user = {
        :user_name => entry.name,
        :full_name => entry.gecos,
        :home_dir => entry.dir,
        # Load any available configuration file
        :config => load_config(entry.dir)
        }
    
      # Update any ~ paths with full home directory path
      user[:config][:folders] &&= user[:config][:folders].map { |path| sub('~', entry.dir) }
    
      # Add the full user to settings
      settings << user
    end
  end
  return settings
end

def filter_from_gitignore(ignorefile)
  result = []
  File.open(ignorefile, "r") do |f|
    while (line = f.gets)
      next if line =~ /^#.*$/
      result << Regexp.new(Regexp.escape(line.strip))
    end
  end if File.exist? ignorefile
  result
end

def folders_from_settings(settings)
  result = {}
  settings.each do |user|
    user[:config].each do |folder, filter|
      filter ||= []       # If no filter is set by user, create empty filter array
      filter << /\.git/i  # Ignore .git folder by default

      result[folder] = {
        :user => user[:user_name],
        :filters => filter.concat(filter_from_gitignore(File.join(folder, ".gitignore")))        
      }
    end
  end
  result
end
