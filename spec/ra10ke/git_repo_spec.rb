# frozen_string_literal: true

require 'spec_helper'
require 'ra10ke/git_repo'

RSpec.describe 'Ra10ke::GitRepo' do
  let(:url) { 'https://github.com/vshn/puppet-gitlab' }

  it '#new' do
    expect(Ra10ke::GitRepo.new(url)).to be_a Ra10ke::GitRepo
  end

  it 'only fetches remote refs once' do
    i = Ra10ke::GitRepo.new(url)
    expect(Git).to receive(:ls_remote).with(url).once.and_return({})
    i.valid_url?
    i.valid_ref?
    i.get_ref_like('1.0.0')
  end

  describe 'good url' do
    let(:url) { 'https://github.com/vshn/puppet-gitlab' }

    let(:instance) do
      Ra10ke::GitRepo.new(url)
    end

    let(:reflist) do
      File.readlines(File.join(fixtures_dir, 'refs', 'gitlab.txt')).each_with_object({}) do |line, refs|
        sha, ref = line.strip.split("\t")
        if ref == 'HEAD'
          refs['head'] = { ref: ref, sha: sha }
        else
          prefix, type, name = ref.split('/', 3)
          type = 'branches' if type == 'heads'
          refs[type] ||= {}
          refs[type][name] = { ref: prefix, sha: sha }
        end
      end
    end

    before do
      allow(Git).to receive(:ls_remote).with(url).and_return(reflist)
    end

    it '#remote_refs returns the gem hash unchanged' do
      expect(instance.remote_refs).to equal(reflist)
    end

    it '#remote_refs contains refs' do
      expect(instance.remote_refs['head']).to eq(ref: 'HEAD', sha: '1b3322d525e96bf7d0565b08703e2a44c90e7b4a')
    end

    it '#get_ref_like' do
      expect(instance.get_ref_like('5.0.0')).to eq('v5.0.0')
    end

    it '#valid_ref?' do
      expect(instance.valid_ref?('master')).to be true
    end

    it 'accepts HEAD explicitly and as the default ref' do
      expect(instance.valid_ref?('HEAD')).to be true
      expect(instance.valid_ref?).to be true
    end

    it 'excludes pull and merge request refs from validation' do
      allow(Git).to receive(:ls_remote).with(url).and_return(
        'pull' => { '74/head' => { ref: 'refs', sha: 'abc12345' } },
        'merge_request' => { '12/merge' => { ref: 'refs', sha: 'def12345' } },
      )
      expect(instance.valid_ref?('74')).to be false
      expect(instance.valid_ref?('abc12345')).to be false
      expect(instance.valid_ref?('12')).to be false
      expect(instance.valid_ref?('def12345')).to be false
    end

    it '#valid_commit?' do
      expect(instance.valid_commit?('master')).to be true
    end

    it '#valid_commit? and nil sha' do
      expect(instance.valid_commit?(nil)).to be false
    end

    it '#valid_commit? but invalid sha' do
      repo = instance_double(Git::Base)
      allow(Git).to receive(:clone).with(url, kind_of(String), bare: true).and_return(repo)
      allow(repo).to receive(:rev_parse).with('invalid^{commit}').and_raise(Git::Error)
      expect(instance.valid_commit?('invalid')).to be false
    end

    it '#valid_url?' do
      expect(instance.valid_url?).to be true
    end

    it 'accepts full and abbreviated SHAs but checks all supplied characters' do
      sha = reflist['head'][:sha]
      expect(instance.valid_ref?(sha)).to be true
      expect(instance.valid_ref?(sha[0, 8])).to be true
      expect(instance.valid_ref?(sha[0, 12])).to be true
      expect(instance.valid_ref?("#{sha[0, 8]}#{'0' * 32}")).to be false
      expect(instance.valid_ref?("#{sha}0")).to be false
      expect(instance.valid_ref?(sha[0, 7])).to be false
    end

    it 'validates the peeled commit SHA of an annotated tag' do
      expect(instance.valid_ref?('1febd15f90d32e6b3d6c242a70db386b2ef1942c')).to be true
    end

    it 'searches only tag names and skips peeled tag entries' do
      allow(Git).to receive(:ls_remote).with(url).and_return(
        'branches' => { 'feature/5.0.0' => { ref: 'refs', sha: 'abc12345' } },
        'tags' => { 'v5.0.0^{}' => { ref: 'refs', sha: 'abc12345' }, 'v5.0.0' => { ref: 'refs', sha: 'def12345' } },
      )
      expect(instance.get_ref_like('5.0.0')).to eq('v5.0.0')
      expect(instance.get_ref_like('feature')).to be_nil
      expect(instance.get_ref_like('^{}')).to be_nil
    end
  end

  describe 'bad url' do
    let(:url) { 'https://github.com/nwops/typo' }
    let(:instance) do
      Ra10ke::GitRepo.new(url)
    end

    before do
      allow(Git).to receive(:ls_remote).with(url).and_raise(Git::Error)
    end

    it 'returns empty remote refs and rejects HEAD' do
      expect(instance.remote_refs).to eq({})
      expect(instance.valid_ref?).to be false
    end
  end

  describe 'failed remote lookup' do
    it 'caches the failure and reports an invalid URL' do
      repo = Ra10ke::GitRepo.new(url)
      expect(Git).to receive(:ls_remote).with(url).once.and_raise(Git::Error)
      expect(repo.valid_url?).to be false
      expect(repo.remote_refs).to eq({})
      expect(repo.get_ref_like('missing')).to be_nil
      expect(Git).not_to receive(:clone)
      expect(repo.valid_commit?('missing')).to be false
    end
  end

  describe '#valid_commit?' do
    let(:instance) { Ra10ke::GitRepo.new(url) }

    before do
      allow(Git).to receive(:ls_remote).with(url).and_return('head' => { ref: 'HEAD', sha: 'a' * 40 })
    end

    it 'does not clone for an empty SHA' do
      expect(Git).not_to receive(:clone)
      expect(instance.valid_commit?('')).to be false
    end

    it 'stops after a failed clone and removes the temporary directory' do
      clone_dir = nil
      expect(Git).to receive(:clone).with(url, kind_of(String), bare: true) do |_, dir|
        clone_dir = dir
        raise Git::Error
      end
      expect(instance.valid_commit?('missing')).to be false
      expect(File.exist?(clone_dir)).to be false
    end
  end

  describe '.current_branch' do
    it 'handles nil returned by older git gem versions for detached HEAD' do
      repo = instance_double(Git::Base, current_branch: nil)
      allow(Git).to receive(:open).with('repo').and_return(repo)
      expect(Ra10ke::GitRepo.current_branch('repo')).to be_nil
    end

    it 'returns nil for a directory without a repository' do
      Dir.mktmpdir do |dir|
        expect(Ra10ke::GitRepo.current_branch(dir)).to be_nil
      end
    end

    it 'returns nil for a missing directory' do
      Dir.mktmpdir do |dir|
        expect(Ra10ke::GitRepo.current_branch(File.join(dir, 'missing'))).to be_nil
      end
    end
  end

  describe 'with a local repository' do
    let(:tmpdir) { Dir.mktmpdir('ra10ke git repo ') }
    let(:path) { File.join(tmpdir, 'source repo') }
    let(:local_repo) { Git.init(path) }
    let(:older_sha) { local_repo.revparse('HEAD~1') }

    around do |example|
      example.run
    ensure
      FileUtils.remove_entry(tmpdir)
    end

    before do
      local_repo.config('user.name', 'Ra10ke Test')
      local_repo.config('user.email', 'ra10ke@example.invalid')
      local_repo.config('commit.gpgsign', 'false')
      local_repo.config('tag.gpgsign', 'false')
      File.write(File.join(path, 'file'), 'first')
      local_repo.add('file')
      local_repo.commit('first')
      File.write(File.join(path, 'file'), 'second')
      local_repo.add('file')
      local_repo.commit('second')
      local_repo.add_tag('v1.0.0')
      local_repo.add_tag('v2.0.0', annotate: true, message: 'annotated tag')
    end

    it 'returns the branch without changing the working directory' do
      cwd = Dir.pwd
      expect(Ra10ke::GitRepo.current_branch(path)).to eq(local_repo.current_branch)
      expect(Dir.pwd).to eq(cwd)
    end

    it 'returns nil for detached HEAD' do
      local_repo.checkout(older_sha)
      expect(Ra10ke::GitRepo.current_branch(path)).to be_nil
    end

    it 'finds branches, lightweight tags and annotated tags' do
      repo = Ra10ke::GitRepo.new(path)
      expect(repo.valid_url?).to be true
      expect(repo.valid_ref?(local_repo.current_branch)).to be true
      expect(repo.valid_ref?('v1.0.0')).to be true
      expect(repo.valid_ref?('v2.0.0')).to be true
      expect(repo.get_ref_like('2.0.0')).to eq('v2.0.0')
    end

    it 'preserves branch and tag names containing slashes' do
      local_repo.branch('feature/example').create
      local_repo.add_tag('release/v1.0.0')
      repo = Ra10ke::GitRepo.new(path)
      expect(repo.valid_ref?('feature/example')).to be true
      expect(repo.valid_ref?('release/v1.0.0')).to be true
      expect(repo.get_ref_like('release/')).to eq('release/v1.0.0')
    end

    it 'recognizes remote HEAD from the gem lookup' do
      repo = Ra10ke::GitRepo.new(path)
      expect(repo.valid_ref?).to be true
      expect(repo.valid_ref?(local_repo.revparse('HEAD'))).to be true
    end

    it 'rejects a blob object during the commit fallback check' do
      repo = Ra10ke::GitRepo.new(path)
      blob_sha = local_repo.rev_parse('HEAD:file')
      expect(repo.valid_commit?(blob_sha)).to be false
    end

    it 'clones to validate a commit that is not advertised by a ref' do
      repo = Ra10ke::GitRepo.new(path)
      expect(repo.valid_ref?(older_sha)).to be false
      expect(repo.valid_commit?(older_sha)).to be true
      expect(repo.valid_commit?('invalid')).to be false
    end
  end
end
