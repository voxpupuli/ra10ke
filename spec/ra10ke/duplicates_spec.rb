# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/duplicates'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Duplicates::Verification' do
  let(:instance) do
    Ra10ke::Duplicates::Verification.new(puppetfile)
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile_with_duplicates')
  end

  it '#new' do
    expect(instance).to be_a Ra10ke::Duplicates::Verification
  end

  it '#duplicates is a hash' do
    expect(instance.duplicates).to be_a Hash
  end

  it '#duplicates is a hash with arrays' do
    expect(instance.duplicates.first.last).to be_a Array
  end

  it '#duplicates is a hash with arrays containing modules' do
    expect(instance.duplicates.first.last.first).to be_a Ra10ke::Duplicates::Verification::Module
  end
end
