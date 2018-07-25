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
  Pattern[/latest|^[.+_0-9:~-]+$/] $release = '0',
  Optional[String] $client_repo             = undef,
  Optional[Array] $channels                 = undef,
  String $epel_key                          = "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}"
) {
  unless $channels {
    fail('Parameter channel is required by os release')
  }
  $package_url = "https://copr-be.cloud.fedoraproject.org/archive/spacewalk/${version}-client/RHEL/${::operatingsystemmajrelease}/x86_64"
  $use_client_repo = $client_repo ? {
    undef   => "${package_url}/spacewalk-client-repo-${version}-${release}.el${::operatingsystemmajrelease}.noarch.rpm",
    default => $client_repo,
  }
  $channel_str = $channels.join(' -c ')

  # module containment 
  contain ::spacewalk::install
  contain ::spacewalk::config
  # module relationship
  Class['::spacewalk::install']
  -> Class['::spacewalk::config']
}
