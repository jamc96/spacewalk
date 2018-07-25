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
  # keys
  file { $spacewalk::epel_key:
    ensure  => $spacewalk::package_ensure,
    mode    => '0644',
    content => template("${module_name}/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}.erb"),
  }
  # repositories
  yumrepo { 'epel':
      ensure         => $spacewalk::package_ensure,
      descr          => "Extra Packages for Enterprise Linux ${::operatingsystemmajrelease} - \$basearch",
      enabled        => '1',
      failovermethod => 'priority',
      gpgcheck       => '1',
      gpgkey         => "file://${spacewalk::epel_key}",
      mirrorlist     => "https://mirrors.fedoraproject.org/metalink?repo=epel-${::operatingsystemmajrelease}&arch=\$basearch",
      require        => File[$spacewalk::epel_key];
  }
  # packages
  package {
    'spacewalk-client-repo':
      provider => 'rpm',
      source   => $spacewalk::use_client_repo;
    ['yum-rhn-plugin','rhn-setup']:
      require => Package['spacewalk-client-repo'];
    ['python-dmidecode','python-hwdata']:
      require => Yumrepo['epel'];
  }
}
