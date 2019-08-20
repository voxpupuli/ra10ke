# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/validate'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Validate::Validation' do
  let(:instance) do
    Ra10ke::Validate::Validation.new(puppetfile)
  end

  let(:result) do
    double
  end

  before(:each) do
    allow(result).to receive(:success?).and_return(true)
    # allow(instance).to receive(:`).with(anything).and_return(result)
    allow($CHILD_STATUS).to receive(:success?).and_return(true)
    allow(instance).to receive(:`).with(anything)
    .and_return(File.read(File.join(fixtures_dir, 'reflist.txt')))
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile')
  end

  it '#new' do
    expect(instance).to be_a Ra10ke::Validate::Validation
  end

  it '#valid_ref?' do
    expect(instance.valid_ref?('https://www.example.com', 'master')).to be true
  end

  it '#valid_commit?' do
    expect(instance.valid_commit?('https://www.example.com', 'master')).to be true
  end

  it '#bad_mods?' do
    allow(instance).to receive(:`).with(anything)
    .and_return(File.read(File.join(fixtures_dir, 'reflist.txt')))
    # because we can't test every single module we return the same result set
    # which only passes for a single module, while others fail.
    expect(instance.bad_mods?).to be true
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
    expect(keys).to eq(%i[name url ref valid_ref? status])
  end

  it '#data is a hash with values' do
    keys = instance.all_modules.first.values

    expect(keys).to eq(['gitlab', 'https://github.com/vshn/puppet-gitlab',
                        '00397b86dfb3487d9df768cbd3698d362132b5bf', true, '👍'])
  end

  it '#all_refs' do
    refs = instance.all_refs('https://www.example.com')
    expect(refs).to be_a Array
    expect(refs.first).to eq(
      {:sha=>"0ec707e431367bbe2752966be8ab915b6f0da754",:name=>"74110ac", :ref=>"refs/heads/74110ac", :subtype=>nil, :type=>:branch}
    )

  end
end
