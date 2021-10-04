# frozen_string_literal: true

require 'ra10ke/puppetfile_parser'
require 'English'
require 'puppet_forge'
require 'table_print'
require 'time'

module Ra10ke::Deprecation
  # Validate the git urls and refs
  def define_task_deprecation(*)
    desc 'Validate that no forge modules are deprecated'
    task :deprecation do
      valid = Ra10ke::Deprecation::Validation.new(get_puppetfile.puppetfile_path)
      exit_code = 0
      if valid.bad_mods?
        exit_code = 1
        message = "\nError: Puppetfile contains deprecated modules."
        tp valid.sorted_mods, :name, :deprecated_at
      else
        message = 'Puppetfile contains no deprecated Forge modules.'
      end
      abort(message) if exit_code.positive?

      puts message
    end
  end

  class Validation
    include Ra10ke::PuppetfileParser

    attr_reader :puppetfile

    def initialize(file)
      file ||= './Puppetfile'
      @puppetfile = File.expand_path(file)
      abort("Puppetfile does not exist at #{puppetfile}") unless File.readable?(puppetfile)
    end

    # @return [Array[Hash]] array of module information and git status
    def deprecated_modules
      @deprecated_modules ||= begin
        deprecated = forge_modules(puppetfile).map do |mod|
          module_name = "#{mod[:namespace] || mod[:name]}-#{mod[:name]}"
          forge_data = PuppetForge::Module.find(module_name)

          next forge_data if forge_data.deprecated_at

          nil
        rescue Faraday::ResourceNotFound
          nil
        end
        deprecated.compact.map do |mod|
          { name: mod.slug, deprecated_at: Time.parse(mod.deprecated_at) }
        end
      end
    end

    # @return [Boolean] - true if there are any bad mods
    def bad_mods?
      deprecated_modules.any?
    end

    # @return [Hash] - sorts the mods based on good/bad
    def sorted_mods
      deprecated_modules.sort_by { |a| a[:name] }
    end
  end
end
