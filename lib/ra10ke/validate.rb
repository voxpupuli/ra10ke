# frozen_string_literal: true

require 'ra10ke/monkey_patches'
require 'table_print'
require 'ra10ke/puppetfile_parser'
require 'English'
require 'ra10ke/git_repo'

module Ra10ke
  module Validate

    GOOD_EMOJI = ENV['GOOD_EMOJI'] || '👍'
    BAD_EMOJI = ENV['BAD_EMOJI'] || '😨'

    # Validate the git urls and refs
    def define_task_validate(*)
      desc 'Validate the git urls and branches, refs, or tags'
      task :validate do
        gitvalididation = Ra10ke::Validate::Validation.new(get_puppetfile.puppetfile_path)
        exit_code = 0
        if gitvalididation.bad_mods?
          exit_code = 1
          message = BAD_EMOJI + '  Not all modules in the Puppetfile are valid. '.red + BAD_EMOJI
        else
          message = GOOD_EMOJI + '  Puppetfile looks good. '.green + GOOD_EMOJI
        end
        tp gitvalididation.sorted_mods, :name, { url: { width: 50 } }, :ref, :status
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
      def all_modules
        @all_modules ||= begin
          git_modules(puppetfile).map do |mod|
            repo = Ra10ke::GitRepo.new(mod[:args][:git])
            ref = mod[:args][:ref] || mod[:args][:tag] || mod[:args][:branch]
            # If using control_branch, try to guesstimate what the target branch should be
            ref = ENV['CONTROL_BRANCH'] || repo.current_branch || ENV['CONTROL_BRANCH_FALLBACK'] || 'main' \
              if ref == ':control_branch'
            valid_ref = repo.valid_ref?(ref) || repo.valid_commit?(mod[:args][:ref])
            {
              name: mod[:name],
              url: repo.url,
              ref: ref,
              valid_url?: repo.valid_url?,
              valid_ref?: valid_ref,
              status: valid_ref ? Ra10ke::Validate::GOOD_EMOJI : Ra10ke::Validate::BAD_EMOJI
            }
          end
        end
      end

      # @return [Boolean] - true if there are any bad mods
      def bad_mods?
        all_modules.find_all { |mod| !mod[:valid_ref?] }.count > 0
      end

      # @return [Hash] - sorts the mods based on good/bad
      def sorted_mods
        all_modules.sort_by { |a| a[:valid_ref?] ? 1 : 0 }
      end
    end
  end
end
