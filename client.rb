require 'listen'


Listen.to("/Users/pwu/Workarea/tmp/abc") do |modified, added, removed|

  if !modified.empty?
  	puts "this file is modified: #{modified}"
  end

  if !added.empty?
  	puts "this file is added: #{added}"
  end

  if !removed.empty?
  	puts "this file is removed: #{removed}"
  end
end
