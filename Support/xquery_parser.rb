#!/usr/bin/env ruby
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require ENV['TM_SUPPORT_PATH'] + "/lib/exit_codes"
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

class XQueryParser
	
  def initialize(args)
    @list = args
  end

  def match_iter(rgxp,str)
    offset = 0
    while m = str.match(rgxp)
      yield [m[0], m.begin(0) + offset, m[0].length]
      str = m.post_match
      offset += m.end(0)
    end
  end
    
  def get_includes
    # count = 0
    includes = []
    # @list
    # blah = @list.scan(/./u)[0..-1].join
    # remove comments
    # comment_starts = []
    # match_iter(/\(:/, @list) do |tok, beg, len|
    #   comment_starts = beg
    # end
    # 
    # comment_ends = []
    # match_iter(/\(:/, @list) do |tok, beg, len|
    #   comment_end = beg
    # end
    # 
    # if comment_starts.count != comment_ends.count
    #   return
    # end
    # 
    # comment_starts.each do |start|
    #   comment_ends.eac
    #   @list[start..-1].each
    # end
    match_iter(/import\s+module[^;]+;/, @list) do |tok, beg, len|
      namespace = $1 if tok =~ /namespace\s+([_a-zA-Z][-_\.a-zA-Z0-9]*)\s*=/
      file = $1 if tok =~ /at\s+\"(.*)\"\s*;/
      file = ENV['TM_PROJECT_DIRECTORY'] + file
      includes << {
        :namespace => namespace,
        :file => file,
        :functions => {}
      }
    end
    includes
  end
  
  def get_functions()
    
    includes = get_includes
    
    names = []
    functions = []
    includes.each do |i|
      namespace = i[:namespace]
      file = i[:file]
      begin
        f = File.read(i[:file])
        
        match_iter(/declare\s+function\s+([_a-zA-Z][-_\.a-zA-Z0-9]*:)?([_a-zA-Z][-_\.a-zA-Z0-9]*)\s*\((.*)\)\s*(as\s+.*)?\s*\{/, f) do |tok, beg, len|
          function_name = $2 if tok =~ /declare\s+function\s+([_a-zA-Z][-_\.a-zA-Z0-9]*:)?([_a-zA-Z][-_\.a-zA-Z0-9]*)/
          parameters = $3 if tok =~ /declare\s+function\s+([_a-zA-Z][-_\.a-zA-Z0-9]*:)?([_a-zA-Z][-_\.a-zA-Z0-9]*)\s*\((.*)\)\s*(as\s+.*)?\s*\{/
          return_type = $5 if tok =~ /declare\s+function\s+([_a-zA-Z][-_\.a-zA-Z0-9]*:)?([_a-zA-Z][-_\.a-zA-Z0-9]*)\s*\((.*)\)\s*(as\s+(.*))?\s*\{/
          # functions << return_type
          params = parameters.split(/,/)
          count = 0
          new_params = params.map do |p|
            count = count + 1
            "${#{count}:#{p.gsub(/\$/, '\\$').strip}}"
          end
          names << "#{namespace}:#{function_name}"
          functions << {
            'display' => "#{namespace}:#{function_name}",
            'insert' => parameters #"(#{new_params.join(", ")})"
          }
        end
      rescue
        # "doh"
      end
    end

    # prune dupes
    pruned_functions = []
    names.uniq!
    blah = nil
    names.each do |name|
      param_counts = []
      params = nil
      functions.each do |f|
        if (f['display'] == name)
          param_counts << f['insert'].split(/,/).count
        end
      end
      
      functions.each do |f|
        if (f['display'] == name)
          pc = f['insert'].split(/,/).count
          if (pc == param_counts.max)
            params = f['insert']
          end
        end
      end

      
      # if (param_counts.max != param_counts.min)        
        splits = params.split(/,/)
        count = 0
        new_params = []
        splits.each do |s|
          count = count + 1
          if (count > param_counts.min)
            new_params << "${#{count}:[#{s.gsub(/\$/, '\\$').strip}]}"
          else
            new_params << "${#{count}:#{s.gsub(/\$/, '\\$').strip}}"
          end
        end
        params = "(#{new_params.join(", ")})"
      # else
      #     params = ""
      # end
      # pruned_functions << params
      pruned_functions << {
        'display' => name,
        'insert' => params
      }
    end
    pruned_functions
  end
end