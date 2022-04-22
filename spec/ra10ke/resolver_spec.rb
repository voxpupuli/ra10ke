# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/resolver'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Resolver::Instance' do
  include Ra10ke::Resolver
  let(:instance) do
    Ra10ke::Resolver::Instance.new(puppetfile)
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile')
  end

  it 'resolves the puppetfile' do
    expect(instance.resolve).to be nil
  end
end
