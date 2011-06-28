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
@path = File.dirname(__FILE__)


#######################################################
# Manage file changes

# Checks to see if the given PID is an active process.
# Params:
# +pid+:: The pid to be investigated
def pid_active?(pid)
  begin
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end
end

def filter_event(folders, line)
  match = /^\/\d+:(\d+):\d+:\d+(.+)/.match line
  if match
    event, file = match[1], match[2]
  
    folders.each do |folder, properties|
      if file.start_with? folder
        properties[:filters].each do |filter|
          return if filter =~ file
        end
        yield folder, event, file
      end
    end
  else
    puts "ENCASE ERROR! - Could not parse line ->"
    puts "#{line}"
  end
end
def fs_events(folders)
  IO.popen("#{@path}/../fetool") do |io|
    io.each_line do |line|
      filter_event(folders, line) do |folder, event, file|
        yield folder, event, file
      end
    end
  end
end
def fs_events_accumulated(folders)
  queue = {}
  folders.each { |f, v| queue[f] = {
    :process => -1,
    :events => []
  } }
  
  fs_events folders do |folder, event, file|
    queue[folder][:events] << { :event => event, :file => file }
    
    if not pid_active?(queue[folder][:process])
      events = queue[folder][:events]
      pid = fork {
        yield folder, events
      }
      Process.detach(pid)
      queue[folder] = {
        :process => pid,
        :events => []
      }
    end
  end
end
