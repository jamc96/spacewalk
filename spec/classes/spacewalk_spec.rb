require 'spec_helper'

describe 'spacewalk' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} with no parameters" do
      let(:facts) { os_facts }

      it 'fails: channels parameter required' do
        expect {
          catalogue
        }.to raise_error(Puppet::PreformattedError, %r{Evaluation Error: Error while evaluating a Function Call, Class\[Spacewalk\]: expects a value for parameter 'channels'}) # rubocop:disable Metrics/LineLength
      end
    end
    context "with channel => [#{os}-channel1, #{os}-channel2]" do
      let(:facts) { os_facts }
      let :params do
        { channels: ["#{os}-channel1", "#{os}-channel2"] }
      end
      # compilation errors
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      # keys
      ["EPEL-#{os_facts[:operatingsystemmajrelease]}", 'Spacewalk-client', 'Spacewalk-nightly'].each do |key|
        it { is_expected.to contain_file("/etc/pki/rpm-gpg/RPM-GPG-KEY-#{key}").with(ensure: 'present', mode: '0644') }
      end
      # yumrepo
      ['epel', 'spacewalk-client', 'spacewalk-client-nightly'].each do |key|
        it { is_expected.to contain_yumrepo(key).with_ensure('present') }
      end
      # packages
      ['yum-rhn-plugin', 'rhn-setup'].each do |key|
        it { is_expected.to contain_package(key).with(ensure: 'present', provider: 'yum', require: 'Yumrepo[spacewalk-client]') }
      end
      ['python-dmidecode', 'python-hwdata'].each do |key|
        it { is_expected.to contain_package(key).with(ensure: 'present', provider: 'yum', require: 'Yumrepo[epel]') }
      end
      # configure spacewalk
      it {
        is_expected.to contain_exec('rhnreg_ks').with(
          unless: 'spacewalk-channel --list',
          command: 'rhnreg_ks --serverUrl=spacewalk.com/XMLRPC --activationkey=default --force',
          notify: 'Exec[spacewalk-channel]',
        )
      }
      it {
        is_expected.to contain_exec('spacewalk-channel').with(
          command: "spacewalk-channel --add -c #{os}-channel1 -c #{os}-channel2 --user root --password default",
        )
      }
    end
  end
end
