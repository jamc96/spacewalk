# spacewalk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk
class spacewalk(
  String $repo_ensure                     = 'present',
  String $package_ensure                  = 'present',
  Optional[String] $server_url            = undef,
  String $user                            = 'root',
  Optional[String] $password              = undef,
  Optional[String] $activationkey         = undef,
  Optional[String] $repo_source           = undef,
  Optional[String] $python_hwdata_source  = undef,
  Optional[String] $epel_repo_key         = undef,
  Optional[String] $epel_mirror_list      = undef,
  Optional[Array] $channels               = undef,
) {
  # global variables
  $python_package_provider = $::operatingsystemmajrelease ? {
      '7'     => 'yum',
      default => 'rpm',
  }
  $use_epel_repo_key = $epel_repo_key ? {
    undef => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
    default => $epel_repo_key,
  }
  $use_epel_mirror_list = $epel_mirror_list ? {
    undef => "https://mirrors.fedoraproject.org/metalink?repo=epel-${::operatingsystemmajrelease}",
    default => $epel_mirror_list,
  }
  $channel_str = $channels.join(' ')

  # module containment 
  contain ::spacewalk::install
  contain ::spacewalk::config
  # module relationship
  Class['::spacewalk::install']
  -> Class['::spacewalk::config']
}
