#!/usr/bin/env /usr/bin/ruby

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

path = File.dirname(__FILE__)

@event_types = {
  '-1' => 'FSE_INVALID',
  '0' => 'FSE_CREATE_FILE',
  '1' => 'FSE_DELETE',
  '2' => 'FSE_STAT_CHANGED',
  '3' => 'FSE_RENAME',
  '4' => 'FSE_CONTENT_MODIFIED',
  '5' => 'FSE_EXCHANGE',
  '6' => 'FSE_FINDER_INFO_CHANGED',
  '7' => 'FSE_CREATE_DIR',
  '8' => 'FSE_CHOWN',
}
@event_types_simple = {
  '-1' => 'Invalid',
  '0' => 'Created',
  '1' => 'Deleted',
  '2' => 'Stat changed',
  '3' => 'Renamed',
  '4' => 'Modified',
  '5' => 'Exchanged',
  '6' => 'Finder info changed',
  '7' => 'Created dir',
  '8' => 'Changed owner',
}

require File.join(path, 'encase_config')

paths   = load_paths(File.join(path, '../paths.conf'))
folder  = ARGV[0]
files   = ARGV[1].split(';')

growl_folder = File.basename(folder)
growl_msg = ""

files.each do |file|
  m = /(\d+)\s(.*)/.match(file)  
  msg = "#{@event_types_simple[m[1]]} - #{m[2]}\n"
  growl_msg += msg
end

puts growl_msg

icon = File.expand_path("#{path}/../icon.png")

# Enter directory
Dir.chdir folder

# Add my changes to stage
puts %x{#{paths['git']} add -A}

# Commit my changes localy
puts %x{#{paths['git']} commit -m "#{files.to_s}"}

# Pull changes from server and merge
pulled = %x{#{paths['git']} pull origin master}

m = /\d+ files changed, \d+ insertions\(\+\), \d+ deletions\(\-\)/.match(pulled)

pull_notification = nil
pull_notification = m.to_s if m

%x{#{paths['realgrowl']} -t "#{growl_folder}" -d "#{pull_notification}" -a "Sync git" -i "#{icon}"} if pull_notification

# Add any merge activities to stage
puts %x{#{paths['git']} add -A}

# Commit merge localy
puts %x{#{paths['git']} commit -m "merge"}

# Push my changes and merges to server
puts %x{#{paths['git']} push origin master}

result = %x{#{paths['git']} status}

%x{#{paths['realgrowl']} -t "#{growl_folder}" -d "#{growl_msg}" -a "Sync git" -i "#{icon}"}
