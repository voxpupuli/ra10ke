module Ra10ke::Syntax
  def define_task_syntax(*_args)
    desc 'Syntax check Puppetfile'
    task :syntax do
      require 'r10k/action/puppetfile/check'

      puppetfile = R10K::Action::Puppetfile::Check.new({
                                                         root: @basedir,
                                                         moduledir: @moduledir,
                                                         puppetfile: @puppetfile_path,
                                                       }, '')

      abort('Puppetfile syntax check failed') unless puppetfile.call
    end
  end
end
