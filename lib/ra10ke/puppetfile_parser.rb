# it might be desirable to parse the Puppetfile as a string instead of evaling it.
# this module allows you to do just that.
require 'ra10ke/monkey_patches'

module Ra10ke
  module PuppetfileParser
    # @return [Array] - returns a array of hashes that contain modules with a git source
    def git_modules(file = puppetfile)
      modules(file).find_all do |mod|
        mod[:args].key?(:git)
      end
    end

    # @return [Array] - returns a array of hashes that contain modules from the Forge
    def forge_modules(file = puppetfile)
      modules(file).reject do |mod|
        mod[:args].key?(:git)
      end
    end

    # @param puppetfile [String] - the absolute path to the puppetfile
    # @return [Array] - returns an array of module hashes that represent the puppetfile
    # @example
    # [{:namespace=>"puppetlabs", :name=>"stdlib", :args=>[]},
    # {:namespace=>"petems", :name=>"swap_file", :args=>["'4.0.0'"]}]
    def modules(puppetfile)
      @modules ||= begin
        return [] unless File.exist?(puppetfile)

        all_lines = File.read(puppetfile).lines.map(&:strip_comment)
        # remove comments from all the lines
        lines_without_comments = all_lines.reject { |line| line.match(/#.*\n/) || line.empty? }.join("\n")
        lines_without_comments.split(/^mod/).map do |line|
          next nil if /^forge/.match?(line)
          next nil if line.empty?

          parse_module_args(line)
        end.compact.uniq
      end
    end

    # @param data [String] - the string to parse the puppetfile args out of
    # @return [Array] -  an array of arguments in hash form
    # @example
    # {:namespace=>"puppetlabs", :name=>"stdlib", :args=>[]}
    # {:namespace=>"petems", :name=>"swap_file", :args=>["'4.0.0'"]}
    def parse_module_args(data)
      return {} if data.empty?

      args = data.split(',').map(&:strip)
      # we can't guarantee that there will be a namespace when git is used
      # remove quotes and dash and slash
      namespace, name = args.shift.gsub(/'|"/, '').split(%r{-|/})
      name ||= namespace
      namespace = nil if namespace == name
      {
        namespace: namespace,
        name: name,
        args: process_args(args),
      }
    end

    # @return [Array] - returns an array of hashes with the args in key value pairs
    # @param [Array] - the arguments processed from each entry in the puppetfile
    # @example
    # [{:args=>[], :name=>"razor", :namespace=>"puppetlabs"},
    #  {:args=>[{:version=>"0.0.3"}], :name=>"ntp", :namespace=>"puppetlabs"},
    #  {:args=>[], :name=>"inifile", :namespace=>"puppetlabs"},
    #  {:args=>
    #    [{:git=>"https://github.com/nwops/reportslack.git"}, {:ref=>"1.0.20"}],
    #   :name=>"reportslack",
    #   :namespace=>"nwops"},
    #  {:args=>{:git=>"git://github.com/puppetlabs/puppetlabs-apt.git"},
    #   :name=>"apt",
    #   :namespace=>nil}
    # ]
    def process_args(args)
      results = {}
      args.each do |arg|
        a = arg.gsub(/'|"/, '').split(/\A:|:\s|=>/).map(&:strip).reject(&:empty?)
        if a.count < 2
          results[:version] = a.first
        else
          results[a.first.to_sym] = a.last
        end
      end
      results
    end
  end
end
