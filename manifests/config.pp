# spacewalk::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include spacewalk::config
class spacewalk::config inherits spacewalk {
  # default parameters
  Exec {
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless  => 'spacewalk-channel --list',
  }
  # subscribe to master server
  exec {
    'rhnreg_ks':
      command  => "rhnreg_ks --serverUrl=${spacewalk::server} --activationkey=${spacewalk::activationkey} --force";
    'spacewalk-channel':
      command => "spacewalk-channel --add -c ${spacewalk::channel_str} --user ${spacewalk::user} --password ${spacewalk::password}",
  }
}
