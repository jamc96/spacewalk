# spacewalk::install
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk::install
class spacewalk::install(
  $spacewalk_ensure      = $::spacewalk::package_ensure,
  $repo_source           = $::spacewalk::repo_source,
  $python_hwdata_source  = $::spacewalk::python_hwdata_source,
  $epel_repo_key         = $::spacewalk::use_epel_repo_key,
  $epel_mirror_list      = $::spacewalk::use_epel_mirror_list,
) {
  yumrepo { 'epel':
    ensure         => 'present',
    descr          => 'Packages for Enterprise Linux - $basearch',
    enabled        => '1',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => $epel_repo_key,
    mirrorlist     => $epel_mirror_list,
  }
  package {
      ['NetworkManager-libnm','NetworkManager-tui','NetworkManager-team','NetworkManager']:
        ensure => 'purged',
        before => Package['spacewalk-client-repo'];
      'spacewalk-client-repo':
        ensure   => $spacewalk_ensure,
        source   => $repo_source,
        provider => 'rpm',
        require  => Yumrepo['epel'];
      'python-hwdata':
        ensure   => 'present',
        source   => $python_hwdata_source,
        provider => $::spacewalk::python_package_provider,
        require  => Package['spacewalk-client-repo'];
      ['rhn-setup','yum-rhn-plugin','python-dmidecode']:
        ensure  => 'present',
        require => Package['python-hwdata'];
    }
}
