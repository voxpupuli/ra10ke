# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/deprecation'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Deprecation::Validation' do
  let(:instance) do
    Ra10ke::Deprecation::Validation.new(puppetfile)
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile')
  end

  it 'only checks forge modules' do
    expect(PuppetForge::Module).not_to receive(:find).with('puppet')
    allow(PuppetForge::Module).to receive(:find).and_raise(Faraday::ResourceNotFound.new(nil))
    expect(instance.deprecated_modules.count).to eq(0)
  end

  it 'handles deprecated modules' do
    expect(PuppetForge::Module).to receive(:find).with('puppetlabs-ruby').and_return(double(slug: 'puppetlabs-ruby',
                                                                                            deprecated_at: '2021-04-22 10:29:42 -0700'))
    allow(PuppetForge::Module).to receive(:find).and_return(double(slug: 'module-module', deprecated_at: nil))

    expect(instance.bad_mods?).to eq(true)
    expect(instance.deprecated_modules.first).to eq(name: 'puppetlabs-ruby',
                                                    deprecated_at: Time.parse('2021-04-22 10:29:42 -0700'))
  end

  it 'handles missing modules' do
    expect(PuppetForge::Module).to receive(:find).with('choria-choria').and_return(double(slug: 'choria-choria',
                                                                                          deprecated_at: nil))
    expect(PuppetForge::Module).to receive(:find).with('puppetlabs-ruby').and_raise(Faraday::ResourceNotFound.new(nil))
    allow(PuppetForge::Module).to receive(:find).and_return(double(slug: 'module-module', deprecated_at: nil))

    expect(instance.bad_mods?).to eq(false)
  end

  describe 'handles large puppetfile' do
    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile_deprecation_issue')
    end

    it 'deprecated modules' do
      expect(instance.bad_mods?).to eq(false)
      expect(instance.deprecated_modules.count).to eq(0)
    end
  end
end
