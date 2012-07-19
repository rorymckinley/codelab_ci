#!/usr/bin/env ruby
#
workbench_dir = '/tmp/workbenches'

workbenches = Dir.entries(workbench_dir)

workbenches.reject! { |workbench| [".", ".."].include? workbench }

workbenches.map! do |workbench|
  workbench_requests = Dir.entries(File.join(workbench_dir, workbench))
  workbench_requests.reject! { |workbench| [".", ".."].include? workbench }
  request_times = workbench_requests.map { |request| File.mtime(File.join(workbench_dir, workbench, request)) }
  { :workbench => workbench, :earliest_request => request_times.sort.first }
end

workbenches.sort! { |x,y| x[:earliest_request] <=> y[:earliest_request] }

# Assume we only have one worker - no forking for now

workbench = workbenches.first[:workbench]

requests = Dir.entries(File.join(workbench_dir, workbench))

requests.reject! { |request| [".", ".."].include? request }

requests.sort! do |first_request, second_request|
  File.mtime(File.join(workbench_dir, workbench, first_request)) <=> File.mtime(File.join(workbench_dir, workbench, second_request))
end

committer = IO.read(File.join(workbench_dir, workbench, requests.first)).chomp

requests.select! { |request| IO.read(File.join(workbench_dir, workbench, request)).chomp == committer }

puts requests.last
