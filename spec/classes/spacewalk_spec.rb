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

      # default variables
      package_url = "https://copr-be.cloud.fedoraproject.org/archive/spacewalk/2.6-client/RHEL/#{os_facts[:operatingsystemmajrelease]}/x86_64"
      epel_key = "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{os_facts[:operatingsystemmajrelease]}"
      # compilation errors
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      # keys
      it { is_expected.to contain_file(epel_key).with(ensure: 'present', mode: '0644') }
      # yumrepo
      it {
        is_expected.to contain_yumrepo('epel').with(
          ensure: 'present',
          descr: "Extra Packages for Enterprise Linux #{os_facts[:operatingsystemmajrelease]} - \$basearch",
          enabled: '1',
          failovermethod: 'priority',
          gpgcheck: '1',
          gpgkey: "file://#{epel_key}",
          mirrorlist: "https://mirrors.fedoraproject.org/metalink?repo=epel-#{os_facts[:operatingsystemmajrelease]}&arch=\$basearch",
          require: "File[#{epel_key}]",
        )
      }
      # packages
      it {
        is_expected.to contain_package('spacewalk-client-repo').with(
          ensure: 'present',
          provider: 'rpm',
          source: "#{package_url}/spacewalk-client-repo-2.6-0.el#{os_facts[:operatingsystemmajrelease]}.noarch.rpm"
        )
      }
      ['yum-rhn-plugin', 'rhn-setup'].each do |key|
        it { is_expected.to contain_package(key).with(ensure: 'present', provider: 'yum', require: 'Package[spacewalk-client-repo]') }
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
