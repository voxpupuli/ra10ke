require 'spec_helper'
require 'ra10ke/puppetfile_parser'

RSpec.describe 'Ra10ke::PuppetfileParser' do
    include Ra10ke::PuppetfileParser

    let(:puppetfile) do
      File.join(fixtures_dir, 'Puppetfile')
    end

    let(:puppetfile_modules) do
        [{:args=>{:version=>"2.2.0"}, :name=>"inifile", :namespace=>"puppetlabs"},
             {:args=>{:version=>"4.24.0"}, :name=>"stdlib", :namespace=>"puppetlabs"},
             {:args=>{:version=>"4.0.0"}, :name=>"concat", :namespace=>"puppetlabs"},
             {:args=>{:version=>"6.4.1"}, :name=>"ntp", :namespace=>"puppetlabs"},
             {:args=>{:version=>"3.1.1"}, :name=>"archive", :namespace=>"puppet"},
             {:args=>
               {:git=>"https://github.com/vshn/puppet-gitlab",
                :ref=>"00397b86dfb3487d9df768cbd3698d362132b5bf"},
              :name=>"gitlab",
              :namespace=>nil},
             {:args=>{:git=>"https://github.com/acidprime/r10k", :tag=>"v3.1.1"},
              :name=>"r10k",
              :namespace=>nil},
             {:args=>
               {:branch=>"gitlab_disable_ssl_verify_support",
                :git=>"https://github.com/npwalker/abrader-gms"},
              :name=>"gms",
              :namespace=>nil},
             {:args=>
               {:git=>"https://github.com/puppetlabs/pltraining-rbac",
                :ref=>"2f60e1789a721ce83f8df061e13f8bf81cd4e4ce"},
              :name=>"rbac",
              :namespace=>"pltraining"},
             {:args=>
               {:branch=>"master", :git=>"https://github.com/dobbymoodge/puppet-acl.git"},
              :name=>"acl",
              :namespace=>"puppet"},
             {:args=>{:branch=>"master", :git=>"https://github.com/cudgel/deploy.git"},
              :name=>"deploy",
              :namespace=>nil},
             {:args=>
               {:branch=>"master", :git=>"https://github.com/cudgel/puppet-dotfiles.git"},
              :name=>"dotfiles",
              :namespace=>nil},
             {:args=>{:branch=>"dev", :git=>"https://github.com/cudgel/splunk.git"},
              :name=>"splunk",
              :namespace=>nil},
             {:args=>{:branch=>"master", :git=>"https://github.com/voxpupuli/puppet-module.git"},
              :name=>"puppet",
              :namespace=>nil}]
    end


    it '#modules' do
        expect(modules(puppetfile)).to eq(puppetfile_modules)
    end

    it '#git_modules' do
        expected = [{:args=>
            {:git=>"https://github.com/vshn/puppet-gitlab",
             :ref=>"00397b86dfb3487d9df768cbd3698d362132b5bf"},
           :name=>"gitlab",
           :namespace=>nil},
          {:args=>{:git=>"https://github.com/acidprime/r10k", :tag=>"v3.1.1"},
           :name=>"r10k",
           :namespace=>nil},
          {:args=>
            {:branch=>"gitlab_disable_ssl_verify_support",
             :git=>"https://github.com/npwalker/abrader-gms"},
           :name=>"gms",
           :namespace=>nil},
          {:args=>
            {:git=>"https://github.com/puppetlabs/pltraining-rbac",
             :ref=>"2f60e1789a721ce83f8df061e13f8bf81cd4e4ce"},
           :name=>"rbac",
           :namespace=>"pltraining"},
          {:args=>
            {:branch=>"master", :git=>"https://github.com/dobbymoodge/puppet-acl.git"},
           :name=>"acl",
           :namespace=>"puppet"},
          {:args=>{:branch=>"master", :git=>"https://github.com/cudgel/deploy.git"},
           :name=>"deploy",
           :namespace=>nil},
          {:args=>
            {:branch=>"master", :git=>"https://github.com/cudgel/puppet-dotfiles.git"},
           :name=>"dotfiles",
           :namespace=>nil},
          {:args=>{:branch=>"dev", :git=>"https://github.com/cudgel/splunk.git"},
           :name=>"splunk",
           :namespace=>nil},
          {:args=>{:branch=>"master", :git=>"https://github.com/voxpupuli/puppet-module.git"},
           :name=>"puppet",
           :namespace=>nil}]
        expect(git_modules(puppetfile)).to eq(expected)
    end

    it '#parse_modules_args' do
        data = " 'puppet-acl',  :git => 'https://github.com/dobbymoodge/puppet-acl.git',  :branch => 'master'"
        expect(parse_module_args(data)).to eq({:args=>{:branch=>"master",
             :git=>"https://github.com/dobbymoodge/puppet-acl.git"},
              :name=>"acl", :namespace=>"puppet"})
    end

    it '#parse_modules_args when empty' do
        data = ""
        expect(parse_module_args(data)).to eq({})
    end
end
