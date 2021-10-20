# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/dependencies'
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'Ra10ke::Dependencies::Verification' do
  after(:each) do
    # reset version formats
    formats = Ra10ke::Dependencies.class_variable_get(:@@version_formats)
    Ra10ke::Dependencies.class_variable_set(:@@version_formats, formats.select { |k, _v| k == :semver } )
  end

  context 'register_version_format' do
    it 'default contains semver' do
      expect(Ra10ke::Dependencies.class_variable_get(:@@version_formats)).to have_key(:semver)
    end
    it 'add new version format' do
      Ra10ke::Dependencies.register_version_format(:test) do |tags|
        nil
      end
      expect(Ra10ke::Dependencies.class_variable_get(:@@version_formats)).to have_key(:test)
    end
  end

  context 'get_latest_ref' do
    let(:instance) do
      class DependencyDummy
        include Ra10ke::Dependencies
      end.new
    end

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
        Ra10ke::Dependencies.register_version_format(:number) do |tags|
          tags.detect { |tag| tag == latest_tag }
        end
        expect(instance.get_latest_ref({
          'tags' => test_tags,
        })).to eq(latest_tag)
      end
    end
  end
end
