#!/usr/bin/env ruby -wKU
require ENV['TM_SUPPORT_PATH'] + "/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require ENV['TM_SUPPORT_PATH'] + '/lib/osx/plist'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

choices = OSX::PropertyList.load(File.read(ENV['TM_BUNDLE_SUPPORT'] + '/functions.plist'))

def caret_position(line)
  tmp = ENV['TM_LINE_NUMBER'].to_i - ENV['TM_INPUT_START_LINE'].to_i - 1
  if tmp > 0
    caret_placement = line.index_of_nth_occurrence_of(tmp,?\n) + ENV['TM_LINE_INDEX'].to_i
  else
    caret_placement =ENV['TM_LINE_INDEX'].to_i-ENV['TM_INPUT_START_LINE_INDEX'].to_i - 1
  end
end

def match_iter(rgxp,str)
  offset = 0
  while m = str.match(rgxp)
    yield [m[0], m.begin(0) + offset, m[0].length]
    str = m.post_match
    offset += m.end(0)
  end
end

class String
  def index_of_nth_occurrence_of(n, ch)
    self.unpack("U*").each_with_index do |e, i|
      return i if e == ch && (n -= 1) == 0
    end
    return -1
  end
end

line = STDIN.read
caret_placement = caret_position(line)

pat = /([^-_\.a-zA-Z0-9][_a-zA-Z][-_\.a-zA-Z0-9]*:?([a-zA-Z][a-zA-Z0-9]*)?)/
matcher = /^([_a-zA-Z][-_\.a-zA-Z0-9]*:?([a-zA-Z][a-zA-Z0-9]*)?)$/

mline = line.gsub(/\n/, " ")
start = [0]

fromstart = mline.scan(/./u)[0..caret_placement].join

match_iter(pat , fromstart) do |tok, beg, len|
  start << beg + 1
end

precaret = fromstart[start[-1]..-1]


match = precaret.match(matcher)
initial_filter = match ? match.to_s.strip : ""

# print "[#{initial_filter}]"
TextMate::UI.complete(choices, :initial_filter => initial_filter, :extra_chars => '_-:')


# #!/usr/bin/env ruby -wKU
# require ENV['TM_SUPPORT_PATH'] + '/lib/osx/plist'
# require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
# 
# choices = OSX::PropertyList.load(File.read(ENV['TM_BUNDLE_SUPPORT'] + '/functions.plist'))
# TextMate::UI.complete(choices, :initial_filter => ENV['TM_CURRENT_WORD'], :extra_chars => '_-:')