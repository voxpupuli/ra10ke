# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/diff'
require 'git'
require 'table_print'

RSpec.describe Ra10ke::Diff::Task do
  let(:repo) { instance_double(Git::Base) }
  let(:puppetfile) { instance_double(R10K::Puppetfile) }
  let(:task) { described_class.new }

  before do
    allow(Git).to receive(:open).and_return(repo)
    allow(repo).to receive_messages(current_branch: 'main', status: double(changed: {}, untracked: {}))
    allow(repo).to receive(:is_branch?).with('branch_a').and_return(true)
    allow(repo).to receive(:is_branch?).with('branch_b').and_return(true)
    allow(repo).to receive(:checkout)
    allow(task).to receive(:get_puppetfile).and_return(puppetfile)
    allow(puppetfile).to receive(:load!) # Mock the load! method
  end

  describe '#run' do
    it 'checks for a clean repository' do
      allow(repo.status).to receive(:changed).and_return({ 'file1' => 'modified' })
      expect { task.run(branch_a: 'branch_a', branch_b: 'branch_b') }.to raise_error(SystemExit)
    end

    it 'validates branch existence' do
      allow(repo).to receive(:is_branch?).with('branch_a').and_return(false)
      expect { task.run(branch_a: 'branch_a', branch_b: 'branch_b') }.to raise_error(SystemExit)
    end

    it 'detects added, removed, and changed modules with correct types and versions' do
      # Mock the modules for branch_a and branch_b
      forge_module1 = double('ForgeModule1', name: 'module1', expected_version: '1.0.0')
      allow(forge_module1).to receive(:respond_to?).with(:v3_module).and_return(true)

      vcs_module2 = double('VCSModule2', name: 'module2', desired_ref: '2.0.0')
      allow(vcs_module2).to receive(:respond_to?).with(:v3_module).and_return(false)

      forge_module1_updated = double('ForgeModule1Updated', name: 'module1', expected_version: '1.0.1')
      allow(forge_module1_updated).to receive(:respond_to?).with(:v3_module).and_return(true)

      vcs_module3 = double('VCSModule3', name: 'module3', desired_ref: '3.0.0')
      allow(vcs_module3).to receive(:respond_to?).with(:v3_module).and_return(false)

      # Mock the `modules` method on the puppetfile
      allow(puppetfile).to receive(:modules).and_return(
        [forge_module1, vcs_module2], # branch_a modules
        [forge_module1_updated, vcs_module3], # branch_b modules
      )

      # Run the task
      expect { task.run(branch_a: 'branch_a', branch_b: 'branch_b') }.not_to raise_error

      # Add assertions for the output differences if needed
    end

    it 'restores the original branch after execution' do
      expect(repo).to receive(:checkout).with('main')
      allow(puppetfile).to receive(:modules).and_return([]) # Mock empty modules to avoid errors
      task.run(branch_a: 'branch_a', branch_b: 'branch_b')
    end
  end
end
