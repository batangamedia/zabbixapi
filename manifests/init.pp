# == Class: zabbix_monitor
#
# This class can work with your Zabbix setup to:
#   - add/remove hosts in your Zabbix
#   - add/remove items/templates/screens/... in your Zabbix
#   - set up alerting
#
# === Parameters
#
# Unknown as of yet.
#
# === Variables
#
#
# === Examples
#
#
# === Authors
#
# Mattias Geniar <m@ttias.be>
#
#
class zabbix_monitor {
  # Install the necessary gems
  package { 'zabbixapi':
    ensure    => installed,
    provider  => gem,
  }

  package { 'ipaddress':
    ensure    => installed,
    provider  => gem,
  }

  # Get all Exported Resources and create the Zabbix Resources accordingly
  # Create all hosts
  Zabbix_monitor_host <<| |>>

  # Link all templates
  Zabbix_monitor_template_apply <<|  |>>
}
