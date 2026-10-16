# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke'

RSpec.describe Ra10ke::Dependencies::Verification do
  let(:modules) do
    Array.new(12) { |index| R10K::Module::Forge.new("example-module#{index}", fixtures_dir, version: '1.0.0') }
  end
  let(:puppetfile) { instance_double(R10K::Puppetfile, load!: nil, modules: modules) }
  let(:verification) { described_class.new(puppetfile) }

  before do
    allow(verification).to receive(:ignored_modules).and_return([])
  end

  it 'uses five parallel threads and preserves Puppetfile order' do
    expect(Parallel).to receive(:map).with(modules, in_threads: 5).and_call_original
    allow(verification).to receive(:process_module) { |mod| { name: mod.title } }

    expect(verification.processed_modules).to eq(modules.map { |mod| { name: mod.title } })
  end

  it 'propagates a network failure' do
    allow(verification).to receive(:process_module).and_raise(SocketError, 'DNS lookup failed')

    expect { verification.processed_modules }.to raise_error(SocketError, 'DNS lookup failed')
  end

  it 'skips ignored modules' do
    allow(verification).to receive(:ignored_modules).and_return(modules.map(&:title))
    expect(verification).not_to receive(:process_module)
    expect(verification.processed_modules).to eq([])
  end
end
