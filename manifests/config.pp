# spacewalk::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk::config
class spacewalk::config(
  $server_url    = $::spacewalk::server_url,
  $activationkey = $::spacewalk::activationkey,
  $epel_repo_key  = $::spaceswalk::use_epel_repo_key,
  $user          = $::spaceswalk::user,
  $password      = $::spaceswalk::password,
  $channel_str   = $::spaceswalk::channel_str,
) {
  Exec {
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless  => 'spacewalk-channel --list',
  }
  exec {
      'rhnreg_ks':
      command  => "rhnreg_ks --serverUrl${server_url} --activationkey=${activationkey} --force";
      'rpm_import':
      command  => "rpm --import ${epel_repo_key}";
      'spacewalk-channel':
      command => "spacewalk-channel --add -c ${channel_str} --user ${user} --password ${password}",
    }
}
