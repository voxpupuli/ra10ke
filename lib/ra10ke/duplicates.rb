# frozen_string_literal: true

require 'ra10ke/monkey_patches'
require 'ra10ke/puppetfile_parser'

module Ra10ke::Duplicates
  def define_task_duplicates(*_args)
    desc "Check Puppetfile for duplicates"
    task :duplicates do
      duplicates = Ra10ke::Duplicates::Verification.new(get_puppetfile.puppetfile_path).duplicates
      exit_code = 0
      if duplicates.any?
        exit_code = 1
        message = 'Error: Duplicates exist in the Puppetfile'

        duplicates.map do |name, sources|
          puts "#{name}:"
          sources.each do |source|
            puts "- #{source}"
          end

          puts
        end
      else
        message = 'Puppetfile is free of duplicates'
      end

      abort(message) if exit_code.positive?
      puts message
    end
  end

  class Verification
    include Ra10ke::PuppetfileParser
    Module = Struct.new(:namespace, :name, :args) do
      def git?
        args.key? :git
      end

      def forge?
        !git?
      end

      def type
        git? ? 'git' : 'forge'
      end

      def to_s
        str = "#{[namespace, name].compact.join '/'}"

        if git?
          ref = args[:ref] || args[:tag] || args[:branch]
          ref_type = (args[:ref] && 'ref') || (args[:tag] && 'tag') || (args[:branch] && 'branch')
          str += " from git on the #{ref_type} #{ref} at #{args[:git]}"
        elsif args.key? :version
          str += " from the forge at version #{args[:version]}"
        end

        str
      end
    end

    attr_reader :puppetfile

    def initialize(file)
      file ||= './Puppetfile'
      @puppetfile = File.expand_path(file)
      abort("Puppetfile does not exist at #{puppetfile}") unless File.readable?(puppetfile)
    end

    def duplicates
      to_ret = {}
      modules(puppetfile).each do |mod|
        (to_ret[mod[:name]] ||= []) << Module.new(mod[:namespace], mod[:name], mod[:args])
      end
      to_ret.select { |_k, v| v.count > 1 }
    end
  end
end
