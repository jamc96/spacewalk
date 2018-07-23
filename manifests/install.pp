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
    provider => 'rpm',
  }
  package {
    'rhn-client-tools':
      source => $spacewalk::use_rhn_client_tools_source;
    'yum-rhn-plugin':
      source  => $spacewalk::use_yum_rhn_plugin_source,
      require => Package['rhn-client-tools'];
    'python-dmidecode':
      source  => $spacewalk::use_python_hwdata_source,
      require => Package['yum-rhn-plugin'];
  }
}
