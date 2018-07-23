require 'spec_helper'

describe 'spacewalk' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} with no parameters" do
      let(:facts) { os_facts }

      it { is_expected.to compile.and_raise_error(%r{Parameter channel is required by os release}) }
    end
    context "with channel => [#{os}-channel1, #{os}-channel2]" do
      let(:facts) { os_facts}
      let :params do 
        { channels: ["#{os}-channel1", "#{os}-channel2"] }
      end

      # default variables
      package_url = "https://copr-be.cloud.fedoraproject.org/archive/spacewalk/2.6-client/RHEL/#{os_facts[:operatingsystemmajrelease]}/x86_64"
      if os_facts[:operatingsystemmajrelease] == '7' 
        python_dmidecode = 'python-dmidecode-3.12.2-2.el7.x86_64.rpm'
      else
        python_dmidecode = 'python-dmidecode-3.10.15-2.el6.x86_64.rpm'
      end
      # compilation errors
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      # validate package installed
      it { 
        is_expected.to contain_package('rhn-client-tools').with(
          ensure: 'present',
          provider: 'rpm',
          source: "#{package_url}/rhn-client-tools-2.6.8-1.el#{os_facts[:operatingsystemmajrelease]}.noarch.rpm"
        )
      }
      it { 
        is_expected.to contain_package('yum-rhn-plugin').with(
          ensure: 'present',
          provider: 'rpm',
          source: "#{package_url}/yum-rhn-plugin-2.6.4-1.el#{os_facts[:operatingsystemmajrelease]}.noarch.rpm"
        )
      }
      it { 
        is_expected.to contain_package('python-dmidecode').with(
          ensure: 'present',
          provider: 'rpm',
          source: "http://mirror.centos.org/centos/#{os_facts[:operatingsystemmajrelease]}/os/x86_64/Packages/#{python_dmidecode}"
        )
      }
      # configure spacewalk
      it { 
        is_expected.to contain_exec('rhnreg_ks').with(
          unless: 'spacewalk-channel --list',
          command:'rhnreg_ks --serverUrl=spacewalk.com --activationkey=default --force',
        ) 
      }
      it { 
        is_expected.to contain_exec('spacewalk-channel').with(
          unless: 'spacewalk-channel --list',
          command: "spacewalk-channel --add -c #{os}-channel1 -c #{os}-channel2 --user root --password default",
        ) 
      }
    end
  end
end
