# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke'

RSpec.describe Ra10ke::Dependencies do
  let(:url) { 'https://example.invalid/module.git' }
  let(:metadata) do
    PuppetForge::V3::Module.new(homepage_url: url, current_release: { metadata: { source: url } })
  end
  let(:forge_module) do
    R10K::Module::Forge.new('example-module', fixtures_dir, version: '1.0.0')
  end
  let(:puppetfile) { instance_double(R10K::Puppetfile, load!: nil, forge: nil, modules: [forge_module]) }
  let(:task_owner) { Ra10ke::RakeTask.new }

  around do |example|
    original_application = Rake.application
    Rake.application = Rake::Application.new
    example.run
  ensure
    Rake.application = original_application
  end

  before do
    allow(forge_module).to receive_messages(v3_module: metadata, name: 'example-module')
    allow(task_owner).to receive(:get_puppetfile).and_return(puppetfile)
  end

  it 'prints the matching tag name returned by GitRepo' do
    allow(Git).to receive(:ls_remote).with(url).and_return(
      'tags' => { 'v1.0.0' => { ref: 'refs', sha: 'abc12345' } },
    )
    expected = <<~PUPPETFILE
      mod 'example-module',
        :git => '#{url}',
        :ref => 'v1.0.0'

    PUPPETFILE
    expect { Rake::Task['r10k:print_git_conversion'].execute }.to output(expected).to_stdout
  end

  it 'prints the existing error message when no tag matches' do
    allow(Git).to receive(:ls_remote).with(url).and_return({})
    expected = <<~PUPPETFILE
      mod 'example-module',
        :git => '#{url}',
        :ref => 'bad url or tag 1.0.0 is missing'

    PUPPETFILE
    expect { Rake::Task['r10k:print_git_conversion'].execute }.to output(expected).to_stdout
  end
end
