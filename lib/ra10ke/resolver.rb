require 'puppetfile-resolver'
require 'puppetfile-resolver/puppetfile/parser/r10k_eval'

module Ra10ke
  module Resolver
    def define_task_resolver(*args)
      desc 'Run the puppetfile Resolver'
      task :resolver do
        resolver = Ra10ke::Resolver::Instance.new(get_puppetfile.puppetfile_path)
        result = resolver.resolve
        # Output resolution validation errors
        result.validation_errors.each { |err| puts "Resolution Validation Error: #{err}\n"}
      end
    end

    class Instance
      attr_reader :puppetfile

      def initialize(puppetfile_path = File.expand_path(Dir.pwd))

        # Parse the Puppetfile into an object model
        content = File.open(puppetfile_path, 'rb') { |f| f.read }

        @puppetfile = ::PuppetfileResolver::Puppetfile::Parser::R10KEval.parse(content)

        # Make sure the Puppetfile is valid
        unless puppetfile.valid?
          puts 'Puppetfile is not valid'
          puppetfile.validation_errors.each { |err| puts err }
          exit 1
        end
      end

      def resolve
        # Create the resolver
        # - Use the document we just parsed (puppetfile)
        # - Don't restrict by Puppet version (nil)
        resolver = ::PuppetfileResolver::Resolver.new(puppetfile, nil)

        # Configure the resolver
        cache                 = nil  # Use the default inmemory cache
        ui                    = nil  # Don't output any information
        module_paths          = []   # List of paths to search for modules on the local filesystem
        allow_missing_modules = true # Allow missing dependencies to be resolved
        opts = { cache: cache, ui: ui, module_paths: module_paths, allow_missing_modules: allow_missing_modules }

        # Resolve
        result = resolver.resolve(opts)
      end
    end
  end
end
