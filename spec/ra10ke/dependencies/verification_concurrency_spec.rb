# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke'
require 'timeout'

RSpec.describe Ra10ke::Dependencies::Verification do
  let(:modules) do
    Array.new(12) { |index| R10K::Module::Forge.new("example-module#{index}", fixtures_dir, version: '1.0.0') }
  end
  let(:puppetfile) { instance_double(R10K::Puppetfile, load!: nil, modules: modules) }
  let(:verification) { described_class.new(puppetfile) }

  before do
    allow(verification).to receive(:ignored_modules).and_return([])
  end

  it 'limits concurrent checks to five and preserves Puppetfile order' do
    started = Queue.new
    release = Queue.new
    mutex = Mutex.new
    checked = []
    used_workers = []
    allow(verification).to receive(:process_module) do |mod|
      mutex.synchronize do
        checked << mod.title
        used_workers << Thread.current
      end
      started << Thread.current
      release.pop
      { name: mod.title }
    end

    coordinator = Thread.new { verification.processed_modules }
    workers = Timeout.timeout(5) { Array.new(5) { started.pop } }
    expect(workers.uniq.size).to eq(5)
    expect(checked.size).to eq(5)
    modules.size.times { release << true }
    results = Timeout.timeout(5) { coordinator.value }

    expect(results.map { |result| result[:name] }).to eq(modules.map(&:title))
    expect(used_workers.uniq.size).to eq(5)
    expect(checked.sort).to eq(modules.map(&:title).sort)
  ensure
    modules.size.times { release << true } if release
    coordinator&.join
  end

  it 'waits for all workers before propagating a network failure' do
    mutex = Mutex.new
    checked = []
    workers = []
    allow(verification).to receive(:process_module) do |mod|
      mutex.synchronize do
        checked << mod.title
        workers << Thread.current
      end
      raise Socket::ResolutionError, 'DNS lookup failed' if mod == modules.first

      { name: mod.title }
    end

    expect { verification.processed_modules }.to raise_error(Socket::ResolutionError, 'DNS lookup failed')
    expect(checked.sort).to eq(modules.map(&:title).sort)
    expect(workers).to all(satisfy { |worker| !worker.alive? })
  end

  it 'skips ignored modules' do
    allow(verification).to receive(:ignored_modules).and_return(modules.map(&:title))
    expect(verification).not_to receive(:process_module)
    expect(verification.processed_modules).to eq([])
  end
end
