Module info
-----------

This is the zabbix_monitor module. It allows you to generate Zabbix host and template information using the Zabbix API.

Howto
-------

Check the manifests/init.pp file for resource collection. You can export resources like;

```puppet
@@zabbix_monitor_host { $::fqdn:
  ensure          => present,
  host            => $::fqdn,
  groups          => 'Puppet Managed',
  ip              => $::ipaddress,
  hostname        => $::fqdn,
  proxy_hostid    => 0, # No proxy
  status          => 0, # Enabled
}
```

And apply templates like:

```puppet
@@zabbix_monitor_template_apply { "zbx_application_general_${::fqdn}":
  ensure      => present,
  template    => 'Linux - General',
  host        => $::fqdn,
  require     => Zabbix_monitor_host [ $::fqdn ],
}
```

Support & Help
--------------

Please log tickets and issues in this repository.
