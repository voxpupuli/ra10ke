# frozen_string_literal: true

require 'ra10ke/monkey_patches'
require 'tempfile'
require 'table_print'
require 'ra10ke/puppetfile_parser'
require 'English'

module Ra10ke
  module Validate

    GOOD_EMOJI = ENV['GOOD_EMOJI'] || '👍'
    BAD_EMOJI = ENV['BAD_EMOJI'] || '😨'

    # Validate the git urls and refs
    def define_task_validate(*args)
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

      # @return [Boolean] - return true if the ref is valid
      # @param url [String] - the git string either https or ssh url
      # @param ref [String] - the ref object, branch name, tag name, or commit sha, defaults to HEAD
      def valid_ref?(url, ref = 'HEAD')
        raise ArgumentError unless ref
        found = all_refs(url).find do |sha, data | 
          # we don't need to bother with these types
          next if data[:type] == :pull || data[:type] == :merge_request     
          # is the name equal to the tag or branch?  Is the commit sha equal?     
          data[:name].eql?(ref) || sha.slice(0,8).eql?(ref.slice(0,8))
        end
        !found.nil?
      end

      # @return [Hash] - a hash of all the refs associated with the remote repository
      # @param url [String] - the git string either https or ssh url
      # @example
      # {"0ec707e431367bbe2752966be8ab915b6f0da754"=>{:ref=>"refs/heads/74110ac", :type=>:branch, :subtype=>nil, :name=>"74110ac"},
        # "07bb5d2d94db222dca5860eb29c184e8970f36f4"=>{:ref=>"refs/pull/74/head", :type=>:pull, :subtype=>:head, :name=>"74"},
        # "156ca9a8ea69e056e86355b27d944e59d1b3a1e1"=>{:ref=>"refs/heads/master", :type=>:branch, :subtype=>nil, :name=>"master"},
        # "fcc0532bbc5a5b65f3941738339e9cc7e3d767ce"=>{:ref=>"refs/pull/249/head", :type=>:pull, :subtype=>:head, :name=>"249"},
        # "8d54891fa5df75890ee15d53080c2a81b4960f92"=>{:ref=>"refs/pull/267/head", :type=>:pull, :subtype=>:head, :name=>"267"} }
      def all_refs(url)
        data = `git ls-remote --symref #{url}`
        raise "Error downloading #{url}" unless $CHILD_STATUS.success?
        data.lines.reduce({}) do |refs, line|
          sha, ref = line.split("\t")
          next refs if sha.eql?('ref: refs/heads/master')
          _, type, name, subtype = ref.chomp.split('/')
          next refs unless name 
          type = :tag if type.eql?('tags')
          type = type.to_sym
          subtype = subtype.to_sym if subtype
          type = :branch if type.eql?(:heads)
          refs[sha] = {ref: ref.chomp, type: type, subtype: subtype, name: name }
          refs
        end
      end

      # @return [Boolean] - return true if the commit sha is valid
      # @param url [String] - the git string either https or ssh url
      # @param ref [String] - the sha id
      def valid_commit?(url, sha)
        return false if sha.nil? || sha.empty?
        return true if valid_ref?(url, sha)
        Dir.mktmpdir do |dir|
          `git clone --no-tags #{url} #{dir} 2>&1 > /dev/null`
          Dir.chdir(dir) do
            `git show #{sha} 2>&1 > /dev/null`
            $CHILD_STATUS.success?
          end
        end
      end

      # @return [Array[Hash]] array of module information and git status
      def all_modules
        begin
          git_modules(puppetfile).map do |mod|
            ref = mod[:args][:ref] || mod[:args][:tag] || mod[:args][:branch]
            valid_ref = valid_ref?(mod[:args][:git], ref) || valid_commit?(mod[:args][:git], mod[:args][:ref])
            {
              name: mod[:name],
              url: mod[:args][:git],
              ref: ref,
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
