# spacewalk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk
class spacewalk(
  String $package_ensure                    = 'present',
  String $server                            = 'spacewalk.com',
  String $user                              = 'root',
  String $password                          = 'default',
  String $activationkey                     = 'default',
  Pattern[/latest|^[.+_0-9:~-]+$/] $version = '2.6',
  Optional[String] $rhn_client_tools_source = undef,
  Optional[String] $python_hwdata_source    = undef,
  Optional[String] $yum_rhn_plugin_source   = undef,
  Optional[Array] $channels                 = undef,
) {
  unless $channels {
    fail('Parameter channel is required by os release')
  }
  $package_url = "https://copr-be.cloud.fedoraproject.org/archive/spacewalk/${version}-client/RHEL/${::operatingsystemmajrelease}/x86_64"
  $use_rhn_client_tools_source = $rhn_client_tools_source ? {
    undef   => "${package_url}/rhn-client-tools-${version}.8-1.el${::operatingsystemmajrelease}.noarch.rpm",
    default => $rhn_client_tools_source,
  }
  $use_yum_rhn_plugin_source = $yum_rhn_plugin_source ? {
    undef   => "${package_url}/yum-rhn-plugin-${version}.4-1.el${::operatingsystemmajrelease}.noarch.rpm",
    default => $yum_rhn_plugin_source,
  }
  $python_dmidecode = $::operatingsystemmajrelease ? {
    '7' => 'python-dmidecode-3.12.2-2.el7.x86_64.rpm',
    default => 'python-dmidecode-3.10.15-2.el6.x86_64.rpm',
  }
  $use_python_hwdata_source = $python_hwdata_source ? {
    undef => "http://mirror.centos.org/centos/${::operatingsystemmajrelease}/os/x86_64/Packages/${python_dmidecode}",
    default => $python_hwdata_source,
  }
  $channel_str = $channels.join(' -c ')

  # module containment 
  contain ::spacewalk::install
  contain ::spacewalk::config
  # module relationship
  Class['::spacewalk::install']
  -> Class['::spacewalk::config']
}
