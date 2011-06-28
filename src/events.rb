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

require File.join(path, 'encase_config')
require File.join(path, 'encase_events')

settings  = load_settings
paths     = load_paths(File.join(path, '../paths.conf'))
folders   = folders_from_settings settings

#######################################################
# Main code
fs_events_accumulated folders do |folder, changes|
  change_str = changes.map { |change|
    file = change[:file].sub(folder, '')
    
    "#{change[:event]} #{file}"
    
  }.join(';')
  
  user = folders[folder][:user]
  
  sync_git = File.join(path, 'sync_git.rb')
  
  puts %x{#{paths['sudo']} -u #{user} #{sync_git} '#{folder}' '#{change_str}'}
end
