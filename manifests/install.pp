# spacewalk::install
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk::install
class spacewalk::install inherits spacewalk {
  # default parameters
  Package {
    ensure   => $spacewalk::package_ensure,
    provider => 'yum',
  }
  Yumrepo {
    ensure         => $spacewalk::yum_repo_ensure,
    enabled        => '1',
    failovermethod => 'priority',
    gpgcheck       => '1',
  }
  File {
    ensure  => $spacewalk::file_ensure,
    mode    => '0644',
  }
  # keys
  file {
    $::spacewalk::epel_key:
      content => template("${module_name}/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}.erb");
    $::spacewalk::spacewalk_client_key:
      content => template("${module_name}/RPM-GPG-KEY-SPACEWALK-CLIENT.erb");
    $::spacewalk::spacewalk_nightly_key:
      content => template("${module_name}/RPM-GPG-KEY-SPACEWALK-NIGHTLY.erb");
  }
  # repositories
  yumrepo {
    'epel':
      descr      => "Extra Packages for Enterprise Linux ${::operatingsystemmajrelease} - \$basearch",
      gpgkey     => "file://${spacewalk::epel_key}",
      mirrorlist => "https://mirrors.fedoraproject.org/metalink?repo=epel-${::operatingsystemmajrelease}&arch=\$basearch",
      require    => File[$spacewalk::epel_key];
    'spacewalk-client':
      descr      => 'Spacewalk Client Tools',
      gpgkey     => "file://${spacewalk::spacewalk_client_key}",
      mirrorlist => "${spacewalk::client_repo}/spacewalk-2.8-client/epel-${::operatingsystemmajrelease}-\$basearch/",
      require    => File[$spacewalk::spacewalk_key];
    'spacewalk-client-nightly':
      descr      => 'Spacewalk Client Nightly Tools',
      gpgkey     => "file://${spacewalk::spacewalk_nightly_key}",
      mirrorlist => "${spacewalk::client_repo}/nightly-client/epel-${::operatingsystemmajrelease}-\$basearch/",
      require    => File[$spacewalk::spacewalk_key];
  }
  # packages
  package {
    ['yum-rhn-plugin','rhn-setup']:
      require => Yumrepo['spacewalk-client'];
    ['python-dmidecode','python-hwdata']:
      require => Yumrepo['epel'];
  }
}
