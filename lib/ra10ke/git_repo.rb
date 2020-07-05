# frozen_string_literal: true

require 'tempfile'

module Ra10ke
  class GitRepo
    attr_reader :url

    REMOTE_REFS_CMD = 'git ls-remote --symref'
    CLONE_CMD = 'git clone --no-tags'
    SHOW_CMD = 'git show'

    def initialize(url)
      @url = url
    end

    # @return [Array] - the raw data from the git ls-remote command as lines array
    # return empty array if url or command failed
    def remote_refs
      @remote_refs ||= begin
        data, success = run_command("#{REMOTE_REFS_CMD} #{url}")
        success ? data.lines : []
      end
    end

    # @return [Boolean] true if the git url is valid
    def valid_url?
      !remote_refs.empty?
    end

    # @return [Boolean] - return true if the commit sha is valid
    # @param url [String] - the git string either https or ssh url
    # @param ref [String] - the sha id
    def valid_commit?(sha)
      return false if sha.nil? || sha.empty?
      return true if valid_ref?(sha)

      # cloning is a last resort if for some reason we cannot
      # remotely get via ls-remote
      Dir.mktmpdir do |dir|
        run_command("#{CLONE_CMD} #{url} #{dir}", silent: true)
        Dir.chdir(dir) do
          _, status = run_command("#{SHOW_CMD} #{sha}", silent: true)
          status
        end
      end
    end

    # @return [Boolean] - return true if the ref is valid
    # @param url [String] - the git string either https or ssh url
    # @param ref [String] - the ref object, branch name, tag name, or commit sha, defaults to HEAD
    def valid_ref?(ref = 'HEAD')
      return false if ref.nil?

      found = all_refs.find do |data|
        # we don't need to bother with these types
        next if data[:type] == :pull || data[:type] == :merge_request

        # is the name equal to the tag or branch?  Is the commit sha equal?
        data[:name].eql?(ref) || data[:sha].slice(0, 8).eql?(ref.slice(0, 8))
      end
      !found.nil?
    end

    # @return [Array] - an array of all the refs associated with the remote repository
    # @param url [String] - the git string either https or ssh url
    # @example
    #   [{:sha=>"0ec707e431367bbe2752966be8ab915b6f0da754", :ref=>"refs/heads/74110ac", :type=>:branch, :subtype=>nil, :name=>"74110ac"},
    #     :sha=>"07bb5d2d94db222dca5860eb29c184e8970f36f4", :ref=>"refs/pull/74/head", :type=>:pull, :subtype=>:head, :name=>"74"},
    #     :sha=>"156ca9a8ea69e056e86355b27d944e59d1b3a1e1", :ref=>"refs/heads/master", :type=>:branch, :subtype=>nil, :name=>"master"},
    #     :sha=>"fcc0532bbc5a5b65f3941738339e9cc7e3d767ce", :ref=>"refs/pull/249/head", :type=>:pull, :subtype=>:head, :name=>"249"},
    #     :sha=>"8d54891fa5df75890ee15d53080c2a81b4960f92", :ref=>"refs/pull/267/head", :type=>:pull, :subtype=>:head, :name=>"267"}]
    def all_refs
      @all_refs ||= begin
        remote_refs.each_with_object([]) do |line, refs|
          sha, ref = line.split("\t")
          next refs if sha.eql?('ref: refs/heads/master')

          _, type, name, subtype = ref.chomp.split('/')
          next refs unless name

          type = :tag if type.eql?('tags')
          type = type.to_sym
          subtype = subtype.to_sym if subtype
          type = :branch if type.eql?(:heads)
          refs << { sha: sha, ref: ref.chomp, type: type, subtype: subtype, name: name }
        end
      end
    end

    # useful for mocking easily
    # @param cmd [String]
    # @param silent [Boolean] set to true if you wish to send output to /dev/null, false by default
    # @return [Array]
    def run_command(cmd, silent: false)
      out_args = silent ? '2>&1 > /dev/null' : '2>&1'
      out = `#{cmd} #{out_args}`
      [out, $CHILD_STATUS.success?]
    end
  end
end
