# frozen_string_literal: true

require 'git'
require 'r10k/puppetfile'

module Ra10ke
  module Diff
    class Task
      attr_reader :repo, :puppetfile

      def initialize
        @repo = Git.open('.')
        @original_branch = repo.current_branch
      end

      def run(branch_a:, branch_b:)
        validate_clean_repo
        validate_branches(branch_a, branch_b)

        modules_a = load_modules(branch_a)
        modules_b = load_modules(branch_b)

        differences = calculate_differences(modules_a, modules_b)
        print_differences(differences)
      ensure
        restore_original_branch
      end

      private

      def validate_clean_repo
        return if repo.status.changed.empty? && repo.status.untracked.empty?

        abort('Git repository is not clean. Please commit or stash your changes before running this task.')
      end

      def validate_branches(branch_a, branch_b)
        return if repo.is_branch?(branch_a) && repo.is_branch?(branch_b)

        abort("One of the branches #{branch_a} or #{branch_b} does not exist.")
      end

      def load_modules(branch)
        repo.checkout(branch)
        puppetfile = get_puppetfile
        puppetfile.load!

        modules = {}
        puppetfile.modules.each do |mod|
          # Determine the type and version based on whether it responds to `v3_module`
          if mod.respond_to?(:v3_module)
            type = 'forge'
            version = mod.expected_version
          else
            type = 'vcs'
            version = mod.desired_ref
          end

          modules[mod.name] = { version: version, type: type }
        end

        modules
      end

      def calculate_differences(modules_a, modules_b)
        all_modules = (modules_a.keys + modules_b.keys).uniq

        differences = []
        all_modules.each do |module_name|
          module_a = modules_a[module_name]
          module_b = modules_b[module_name]

          version_a = module_a&.dig(:version)
          version_b = module_b&.dig(:version)
          type_a = module_a&.dig(:type)
          type_b = module_b&.dig(:type)

          if version_a && version_b && (version_a != version_b || type_a != type_b)
            differences << {
              name: module_name,
              version_a: version_a,
              version_b: version_b,
              type_a: type_a,
              type_b: type_b,
              status: 'changed',
            }
          elsif version_a && !version_b
            differences << {
              name: module_name,
              version_a: version_a,
              version_b: nil,
              type_a: type_a,
              type_b: nil,
              status: 'removed',
            }
          elsif !version_a && version_b
            differences << {
              name: module_name,
              version_a: nil,
              version_b: version_b,
              type_a: nil,
              type_b: type_b,
              status: 'added',
            }
          end
        end

        differences
      end

      def print_differences(differences)
        tp differences, :name, :version_a, :version_b, :type_a, :type_b, :status
      end

      def restore_original_branch
        repo.checkout(@original_branch)
      end

      def get_puppetfile
        R10K::Puppetfile.new(Dir.pwd)
      end
    end

    def define_task_diff(*_args)
      desc 'Check for module differences between two branches of a Puppetfile'
      task :diff, [:branch_a, :branch_b] do |_task, args|
        Task.new.run(branch_a: args[:branch_a], branch_b: args[:branch_b])
      end
    end
  end
end
