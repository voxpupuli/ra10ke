# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke'

RSpec.describe Ra10ke::RakeTask do
  before do
    @original_application = Rake.application
    Rake.application = Rake::Application.new
  end

  after do
    Rake.application = @original_application
  end

  it 'uses one check for the table and exit status' do
    owner = described_class.new
    puppetfile = instance_double(R10K::Puppetfile, forge: nil, 'environment=': nil)
    verification = instance_double(Ra10ke::Dependencies::Verification)
    outdated = [{ name: 'example-module', message: :outdated }]
    allow(owner).to receive(:get_puppetfile).and_return(puppetfile)
    allow(Ra10ke::Dependencies::Verification).to receive(:new).with(puppetfile).and_return(verification)
    expect(verification).to receive(:outdated).once.and_return(outdated)
    expect(verification).to receive(:print_table).with(outdated)
    allow(owner).to receive(:abort) { raise SystemExit, 1 }

    expect { Rake::Task['r10k:dependencies'].execute }.to raise_error(SystemExit)
  end
end
