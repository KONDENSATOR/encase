#!/usr/bin/env ruby

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

require 'rubygems'
require File.join(path, 'encase_config')

paths         = load_paths
folder        = ARGV[0]
growl_folder  = File.basename(folder)
icon          = File.expand_path("#{path}/../icon.png")

# Enter directory
Dir.chdir folder

# Pull changes from server and merge
pulled = %x{#{paths['git']} pull origin master}

m = /\d+ files changed, \d+ insertions\(\+\), \d+ deletions\(\-\)/.match(pulled)

pull_notification = nil
pull_notification = m.to_s if m

%x{#{paths['realgrowl']} -t "#{growl_folder}" -d "#{pull_notification}" -a "Sync git" -i "#{icon}"} if pull_notification
