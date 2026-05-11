# frozen_string_literal: true

require 'spec_helper'

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe Ra10ke::Solve do
  # Minimal helper class that mixes in the module so we can test its private methods.
  let(:instance) do
    klass = Class.new do
      include Ra10ke::Solve

      # Expose private helpers for direct testing.
      public :get_key_or_sym, :get_version_req, :print_module_diff, :add_reqs_to_graph

      def initialize
        @graph             = Solve::Graph.new
        @processed_modules = Set.new
        @demands           = Set.new
        # @metadata_cache is intentionally left nil here; tests that need it
        # set it via instance_variable_set in a before block.
      end
    end
    klass.new
  end

  let(:processed_modules) { instance.instance_variable_get(:@processed_modules) }
  let(:demands)           { instance.instance_variable_get(:@demands) }
  let(:graph)             { instance.instance_variable_get(:@graph) }

  # -------------------------------------------------------------------------
  describe '#get_key_or_sym' do
    it 'fetches a value by symbol key' do
      expect(instance.get_key_or_sym({ version: '1.0.0' }, :version)).to eq('1.0.0')
    end

    it 'fetches a value by string key when only the string form is present' do
      expect(instance.get_key_or_sym({ 'version' => '2.0.0' }, :version)).to eq('2.0.0')
    end

    it 'prefers the symbol key over the string key when both are present' do
      expect(instance.get_key_or_sym({ version: 'sym', 'version' => 'str' }, :version)).to eq('sym')
    end

    it 'returns nil when the key is absent in both forms' do
      expect(instance.get_key_or_sym({}, :version)).to be_nil
    end
  end

  # -------------------------------------------------------------------------
  describe '#get_version_req' do
    it 'returns version_requirement when present' do
      expect(instance.get_version_req({ version_requirement: '>= 1.0.0' })).to eq('>= 1.0.0')
    end

    it 'falls back to version_range when version_requirement is absent' do
      expect(instance.get_version_req({ version_range: '>= 2.0.0' })).to eq('>= 2.0.0')
    end

    it 'returns nil when neither key is present' do
      expect(instance.get_version_req({})).to be_nil
    end

    it 'works with string keys' do
      expect(instance.get_version_req({ 'version_requirement' => '~> 3.0' })).to eq('~> 3.0')
    end
  end

  # -------------------------------------------------------------------------
  describe '#print_module_diff' do
    it 'reports OUTDATED for a module whose version has changed' do
      expect do
        instance.print_module_diff([['foo-bar', '1.0.0']], [['foo-bar', '2.0.0']])
      end.to output(/OUTDATED.*foo-bar.*1\.0\.0.*2\.0\.0/).to_stdout
    end

    it 'reports MISSING for a module present in the resolution but not in current' do
      expect do
        instance.print_module_diff([], [['missing-mod', '1.2.3']])
      end.to output(/MISSING.*missing-mod.*1\.2\.3/).to_stdout
    end

    it 'produces no output when all modules are up to date' do
      expect do
        instance.print_module_diff([['foo-bar', '1.0.0']], [['foo-bar', '1.0.0']])
      end.not_to output.to_stdout
    end

    it 'reports all outdated modules in a single pass' do
      current    = [['aaa-one', '1.0.0'], ['bbb-two', '2.0.0']]
      resolution = [['aaa-one', '1.1.0'], ['bbb-two', '2.1.0']]
      expect do
        instance.print_module_diff(current, resolution)
      end.to output(/aaa-one.*bbb-two/m).to_stdout
    end
  end

  # -------------------------------------------------------------------------
  describe '#add_reqs_to_graph' do
    let(:artifact) { graph.artifact('mymod', '1.0.0') }

    context 'when the dependency is already in @processed_modules' do
      before { processed_modules.add('puppetlabs-stdlib') }

      it 'does not attempt a Forge lookup' do
        meta = { name: 'mymod', dependencies: [{ name: 'puppetlabs/stdlib', version_requirement: '>= 4.0.0' }] }
        expect(PuppetForge::Module).not_to receive(:find)
        instance.add_reqs_to_graph(artifact, meta)
      end

      it 'adds the dependency name to @demands' do
        meta = { name: 'mymod', dependencies: [{ name: 'puppetlabs/stdlib', version_requirement: '>= 4.0.0' }] }
        instance.add_reqs_to_graph(artifact, meta)
        expect(demands).to include('puppetlabs-stdlib')
      end

      it 'records the version constraint on the artifact' do
        meta = { name: 'mymod', dependencies: [{ name: 'puppetlabs/stdlib', version_requirement: '>= 4.0.0' }] }
        instance.add_reqs_to_graph(artifact, meta)
        dep = artifact.dependencies.find { |d| d.name == 'puppetlabs-stdlib' }
        expect(dep).not_to be_nil
        expect(dep.constraint.to_s).to eq('>= 4.0.0')
      end
    end

    context 'when no_demands flag is set' do
      before { processed_modules.add('puppetlabs-stdlib') }

      it 'does not add the dependency to @demands' do
        meta = { name: 'mymod', dependencies: [{ name: 'puppetlabs/stdlib', version_requirement: '>= 4.0.0' }] }
        instance.add_reqs_to_graph(artifact, meta, :no_demands)
        expect(demands).not_to include('puppetlabs-stdlib')
      end
    end

    context 'when dependency has an invalid version constraint' do
      before { processed_modules.add('puppetlabs-badmod') }

      it 'prints a warning and continues without raising' do
        meta = { name: 'mymod', dependencies: [{ name: 'puppetlabs/badmod', version_requirement: 'not_valid' }] }
        expect do
          instance.add_reqs_to_graph(artifact, meta)
        end.to output(/WARNING.*Invalid version constraint/).to_stdout
      end
    end

    context 'when dependency has no version constraint' do
      before { processed_modules.add('puppetlabs-nover') }

      it 'falls back to >=0.0.0 and does not raise' do
        meta = { name: 'mymod', dependencies: [{ name: 'puppetlabs/nover' }] }
        expect { instance.add_reqs_to_graph(artifact, meta) }.not_to raise_error
        dep = artifact.dependencies.find { |d| d.name == 'puppetlabs-nover' }
        expect(dep.constraint.to_s).to eq('>= 0.0.0')
      end
    end

    context 'when dependency has a compound constraint (>=x <y)' do
      before { processed_modules.add('puppetlabs-compound') }

      it 'records both bounds on the artifact' do
        meta = {
          name: 'mymod',
          dependencies: [{ name: 'puppetlabs/compound', version_requirement: '>= 4.0.0 <9.0.0' }],
        }
        instance.add_reqs_to_graph(artifact, meta)
        constraints = artifact.dependencies.select { |d| d.name == 'puppetlabs-compound' }
                              .map { |d| d.constraint.to_s }
        expect(constraints).to include('>= 4.0.0')
        expect(constraints).to include('< 9.0.0')
      end
    end
  end
end
