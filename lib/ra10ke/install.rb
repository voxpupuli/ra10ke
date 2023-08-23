module Ra10ke::Install
  def define_task_install(*_args)
    desc 'Install modules specified in Puppetfile'
    task :install do
      require 'r10k/puppetfile'

      puppetfile = get_puppetfile
      puppetfile.load!

      puts 'Processing Puppetfile for fixtures'
      puppetfile.modules.each do |mod|
        if mod.status == :insync
          puts "Skipping #{mod.name} (#{mod.version}) already in sync"
        else
          msg = if mod.status == :absent
                  "installed #{mod.name}"
                else
                  "updated #{mod.name} from #{mod.version} to"
                end
          mod.sync
          if mod.status == :insync
            puts "Successfully #{msg} #{mod.version}".green
          else
            puts "Failed to sync #{mod.name}".red
          end
        end
      end

      puppetfile.purge! if @purge
    end
  end
end
