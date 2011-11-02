prefix = $1 if File.read(ARGV[0]) =~ /^(?:\s*)module(?:\s+)namespace(?:\s+)([_a-zA-Z][-_\.a-zA-Z0-9]*)/
puts prefix ? prefix : "local"