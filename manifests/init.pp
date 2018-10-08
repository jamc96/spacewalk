# spacewalk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk
class spacewalk(
  Array $channels,
  String $package_ensure                    = 'present',
  String $server                            = 'spacewalk.com',
  String $user                              = 'root',
  String $password                          = 'default',
  String $activationkey                     = 'default',
  String $api                               = 'XMLRPC',
  Pattern[/^[.+_0-9:~-]+$/] $version        = '2.8',
  Pattern[/^[.+_0-9:~-]+$/] $release        = '0',
  String $client_repo                       = 'https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject',
  String $gpg_key_path                      = '/etc/pki/rpm-gpg/',
  String $epel_key                          = "${gpg_key_path}/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
  String $spacewalk_client_key              = "${gpg_key_path}/RPM-GPG-KEY-Spacewalk-client",
  String $spacewalk_nightly_key             = "${gpg_key_path}/RPM-GPG-KEY-Spacewalk-nightly",
  String $yum_repo_ensure                   = 'present',
  String $file_ensure                       = 'present',
) {
  $channel_str = $channels.join(' -c ')

  # module containment 
  contain ::spacewalk::install
  contain ::spacewalk::config
  # module relationship
  Class['::spacewalk::install']
  -> Class['::spacewalk::config']
}
