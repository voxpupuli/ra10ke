# frozen_string_literal: true
require 'r10k/puppetfile'
require 'spec_helper'
require 'ra10ke/dependencies'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Dependencies::Verification' do
  let(:instance) do
    pfile = R10K::Puppetfile.new(File.basename(puppetfile), nil,puppetfile, nil, false)
    Ra10ke::Dependencies::Verification.new(pfile)
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile')
  end

  context 'register_version_format' do
    it 'default contains semver' do
      expect(Ra10ke::Dependencies::Verification.version_formats).to have_key(:semver)
    end
    it 'add new version format' do
      Ra10ke::Dependencies::Verification.register_version_format(:test) do |tags|
        nil
      end
      expect(Ra10ke::Dependencies::Verification.version_formats).to have_key(:test)
    end
  end

  context 'show output in table format' do
    let(:instance) do
      pfile = R10K::Puppetfile.new(File.basename(puppetfile), nil,puppetfile, nil, false)
      Ra10ke::Dependencies::Verification.new(pfile)
    end
  
    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile')
    end

    let(:processed_modules) do
      instance.outdated
    end

    it 'have dependencies array' do
      expect(processed_modules).to be_a Array
    end

    it 'show dependencies as table' do
      instance.print_table(processed_modules)
    end

  end

  context 'get_latest_ref' do

    context 'find latest semver tag' do
      let(:latest_tag) do
          'v1.1.0'
      end
      let(:test_tags) do
        {
          'v1.0.0'   => nil,
          latest_tag => nil,
        }
      end

      it do
        expect(instance.get_latest_ref({
          'tags' => test_tags,
        })).to eq(latest_tag)
      end
    end

    context 'find latest tag with custom version format' do
      let(:latest_tag) do
        'latest'
      end
      let(:test_tags) do
        {
          'dev'      => nil,
          latest_tag => nil,
        }
      end

      it do
        Ra10ke::Dependencies::Verification.register_version_format(:number) do |tags|
          tags.detect { |tag| tag == latest_tag }
        end
        expect(instance.get_latest_ref({
          'tags' => test_tags,
        })).to eq(latest_tag)
      end
     end
  end
end
