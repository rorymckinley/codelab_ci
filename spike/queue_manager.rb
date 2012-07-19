#!/usr/bin/env ruby
#
workbench_dir = '/tmp/workbenches'

workbenches = Dir.entries(workbench_dir)

workbenches.reject! { |workbench| [".", ".."].include? workbench }

workbenches.map! do |workbench|
  workbench_requests = Dir.entries(File.join(workbench_dir, workbench))
  workbench_requests.reject! { |workbench| [".", ".."].include? workbench }
  request_times = workbench_requests.map { |request| File.ctime(File.join(workbench_dir, workbench, request)) }
  { :workbench => workbench, :earliest_request => request_times.sort.first }
end

workbenches.sort! { |x,y| x[:earliest_request] <=> y[:earliest_request] }

p workbenches
