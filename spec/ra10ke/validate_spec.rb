# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/validate'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Validate::Validation' do
  let(:instance) do
    Ra10ke::Validate::Validation.new(puppetfile)
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile')
  end

  before do
    allow_any_instance_of(Ra10ke::GitRepo).to receive(:valid_ref?).and_return(true)
    allow_any_instance_of(Ra10ke::GitRepo).to receive(:valid_url?).and_return(true)
  end

  describe 'with commit' do
    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile_with_commit')
    end

    it '#data is a hash with values' do
      keys = instance.all_modules.first.values
      expect(keys).to eq(['ntp', 'https://github.com/puppetlabs/puppetlabs-ntp', '81b34c6', true, true, '👍'])
    end
  end

  describe 'bad url' do
    let(:instance) do
      Ra10ke::Validate::Validation.new(puppetfile)
    end

    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile_with_bad_refs')
    end

    before do
      working = double('Ra1ke::GitRepo', url: 'https://github.com/vshn/puppet-gitlab')
      expect(working).to receive(:valid_ref?).with('00397b86dfb3487d9df768cbd3698d362132b5bf').and_return(false)
      expect(working).to receive(:valid_commit?).with('00397b86dfb3487d9df768cbd3698d362132b5bf').and_return(true)
      expect(working).to receive(:valid_url?).and_return(true)
      bad_tag = double('Ra1ke::GitRepo', url: 'https://github.com/acidprime/r10k')
      expect(bad_tag).to receive(:valid_ref?).with('bad').and_return(false)
      expect(bad_tag).to receive(:valid_commit?).with(nil).and_return(false)
      expect(bad_tag).to receive(:valid_url?).and_return(true)
      bad_url = double('Ra1ke::GitRepo', url: 'https://github.com/nwops/typo')
      expect(bad_url).to receive(:valid_ref?).with(nil).and_return(false)
      expect(bad_url).to receive(:valid_commit?).with(nil).and_return(false)
      expect(bad_url).to receive(:valid_url?).and_return(false)

      expect(Ra10ke::GitRepo).to receive(:new).and_return(working, bad_tag, bad_url)
    end

    it 'details mods that are bad' do
      expect(instance.all_modules.find { |m| !m[:valid_url?] }).to be_a Hash
      expect(instance.all_modules.find_all { |m| !m[:valid_ref?] }.count).to eq(2)
    end
  end

  describe 'control_branch' do
    before do
      ENV.delete 'CONTROL_BRANCH'
      ENV.delete 'CONTROL_BRANCH_FALLBACK'
    end

    let(:instance) do
      Ra10ke::Validate::Validation.new(puppetfile)
    end

    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile_with_control_branch')
    end

    it 'correctly replaces control branch' do
      ENV['CONTROL_BRANCH'] = 'env-control_branch'
      expect(instance.all_modules.find { |m| m[:name] == 'hiera_control' }[:ref]).to eq('env-control_branch')
    end

    it 'correctly detects current branch' do
      allow(Ra10ke::GitRepo).to receive(:current_branch).and_return('current_branch-control_branch')
      expect(instance.all_modules.find { |m| m[:name] == 'hiera_control' }[:ref]).to eq('current_branch-control_branch')
    end

    it 'correctly falls back if no current branch' do
      ENV['CONTROL_BRANCH_FALLBACK'] = 'env-control_branch_fallback'
      allow(Ra10ke::GitRepo).to receive(:current_branch).and_return(nil)
      expect(instance.all_modules.find { |m| m[:name] == 'hiera_control' }[:ref]).to eq('env-control_branch_fallback')
    end

    it 'correctly falls back to default_branch if no current branch' do
      allow(Ra10ke::GitRepo).to receive(:current_branch).and_return(nil)
      expect(instance.all_modules.find { |m| m[:name] == 'hiera_controlwithdefault' }[:ref]).to eq('master')
    end

    it 'correctly falls back to fallback if no current branch but default branch' do
      ENV['CONTROL_BRANCH_FALLBACK'] = 'env-control_branch_fallback'
      allow(Ra10ke::GitRepo).to receive(:current_branch).and_return(nil)
      expect(instance.all_modules.find do |m|
               m[:name] == 'hiera_controlwithdefault'
             end[:ref]).to eq('env-control_branch_fallback')
    end

    it 'correctly falls back to default_branch if no current branch with override' do
      allow(Ra10ke::GitRepo).to receive(:current_branch).and_return(nil)
      expect(instance.all_modules.find { |m| m[:name] == 'hiera_controlwithdefaultoverride' }[:ref]).to eq('master')
    end

    it 'correctly falls back to main if no current branch and no fallback' do
      allow(Ra10ke::GitRepo).to receive(:current_branch).and_return(nil)
      expect(instance.all_modules.find { |m| m[:name] == 'hiera_control' }[:ref]).to eq('main')
    end
  end

  it '#new' do
    expect(instance).to be_a Ra10ke::Validate::Validation
  end

  it '#all_modules is an array' do
    expect(instance.all_modules).to be_a Array
  end

  it '#sorted_mods is an array' do
    expect(instance.sorted_mods).to be_a Array
  end

  it '#data is a hash' do
    expect(instance.all_modules.first).to be_a Hash
  end

  it '#data is a hash with keys' do
    keys = instance.all_modules.first.keys
    expect(keys).to eq(%i[name url ref valid_url? valid_ref? status])
  end

  it '#data is a hash with values' do
    keys = instance.all_modules.first.values

    expect(keys).to eq(['gitlab', 'https://github.com/vshn/puppet-gitlab',
                        '00397b86dfb3487d9df768cbd3698d362132b5bf', true, true, '👍',])
  end
end
