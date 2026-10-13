# frozen_string_literal: true

require 'git'
require 'tmpdir'

module Ra10ke
  class GitRepo
    attr_reader :url

    def initialize(url)
      @url = url
    end

    # Get the current branch for a Git repo
    # @param path [String] - The path to the repository to check
    # @return [String] - The current active branch of the Git repo
    def self.current_branch(path)
      branch = Git.open(path).current_branch
      branch unless branch == 'HEAD' || branch.to_s.empty?
    rescue Git::Error, ArgumentError
      nil
    end

    # @return [Hash] - remote refs grouped by the git gem
    # return empty hash if the command failed
    def remote_refs
      @remote_refs ||= begin
        Git.ls_remote(url)
      rescue Git::Error
        {}
      end
    end

    # @return [Boolean] true if the git url is valid
    def valid_url?
      !remote_refs.empty?
    end

    def valid_commit?(ref)
      return false if ref.nil? || ref.empty?
      return true if valid_ref?(ref)
      return false unless valid_url?

      Dir.mktmpdir do |dir|
        repo = Git.clone(url, dir, bare: true)
        repo.rev_parse("#{ref}^{commit}")
        true
      end
    rescue Git::Error
      false
    end

    # @param ref [String] branch name, tag name, HEAD, or a full/abbreviated SHA
    # @return [Boolean]
    def valid_ref?(ref = 'HEAD')
      return false if ref.nil? || ref.empty?

      head = remote_refs.fetch('head', {})
      return true if ref == 'HEAD' && !head.empty?
      return true if sha_match?(head[:sha], ref)

      %w[branches tags].any? do |type|
        refs = remote_refs.fetch(type, {})
        refs.key?(ref) || refs.values.any? { |data| sha_match?(data[:sha], ref) }
      end
    end

    # @param ref_name [String] substring to find in a tag name
    # @return [String, nil] matching tag name
    def get_ref_like(ref_name)
      return nil if ref_name.nil? || ref_name.empty?

      remote_refs.fetch('tags', {}).each_key.find do |name|
        !name.end_with?('^{}') && name.include?(ref_name)
      end
    end

    private

    def sha_match?(sha, ref)
      return false unless sha

      # \A and \z anchor the entire string; [0-9a-f] allows only hexadecimal digits.
      # {8,64} accepts abbreviations of at least 8 digits up to a full SHA-256; i allows uppercase.
      return false unless ref.match?(/\A[0-9a-f]{8,64}\z/i)

      sha.start_with?(ref.downcase)
    end
  end
end
