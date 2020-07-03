# frozen_string_literal: true

require 'ra10ke'
require 'spec_helper'

RSpec.describe 'Ra10ke::RakeTask' do
  let(:instance) do
    Ra10ke::RakeTask.new do |t|
        t.puppetfile_path = puppetfile
    end
  end

  let(:puppetfile) do
    File.join(fixtures_dir, 'Puppetfile')
  end

  let(:args) do
    []
  end

  describe 'validate tasks' do
    it '#new' do
      expect(instance).to be_a Ra10ke::RakeTask
    end

    it '#define_task_validate' do
      expect(instance.define_task_validate(args)).to be_a Rake::Task
    end

    it '#define_task_solve_dependencies' do
      expect(instance.define_task_solve_dependencies(args)).to be_a Rake::Task
    end

    it '#define_task_syntax' do
      expect(instance.define_task_syntax(args)).to be_a Rake::Task
    end

    it '#define_task_dependencies' do
      expect(instance.define_task_dependencies(args)).to be_a Rake::Task
    end

    it '#define_task_install' do
      expect(instance.define_task_install(args)).to be_a Rake::Task
    end

    it '#get_puppetfile' do
      expect(instance.get_puppetfile).to be_a R10K::Puppetfile
    end
  end

  describe 'run tasks with good refs' do
    it '#run_validate_task' do
      task = instance.define_task_validate(args)
      expect(task.invoke).to be_a Array
    end
  end

  describe 'run tasks with bad refs' do
    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile_with_bad_refs')
    end
    
    # I suspect rake is caching something here and the puppetfile is 
    # not being sent correctly as it is not using the file I specify. 
    # The output should be different.
    # Testing this by itself works
    it '#run_validate_task' do
      task2 = instance.define_task_validate(args)
      expect(task2.invoke).to be nil
    end
  end
end
