# This class configures the puppet_webhook API server.
#
# @summary Configures puppet_webhook API server.
#
# @author Vox Pupuli <voxpupuli@groups.io>
#
# @api private
#
class puppetwebhook::config {
  assert_private()

  group { $puppetwebhook::webhook_group:
    ensure => 'present',
  }

  user { $puppetwebhook::webhook_user:
    ensure  => 'present',
    groups  => $puppetwebhook::webhook_group,
    #shell   => '',
    require => Group[$puppetwebhook::webhook_group],
    before  => Systemd::Unit_file['puppet_webhook.service'],
  }

  file {
    default:
      owner => 'root',
      group => $puppetwebhook::webhook_group,
      mode  => '0640',
      ;
    '/etc/puppet_webhook':
      ensure  => directory,
      mode    => '0775',
      require => Package['puppet_webhook'],
      ;
    '/etc/puppet_webhook/server.yml':
      ensure  => file,
      content => to_yaml($puppetwebhook::server_cfg),
      notify  => Service['puppet_webhook'],
      ;
    '/etc/puppet_webhook/app.yml':
      ensure  => file,
      content => to_yaml($puppetwebhook::app_cfg),
      notify  => Service['puppet_webhook'],
      ;
    "${puppetwebhook::envfile_path}/puppet_webhook":
      ensure  => file,
      content => "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin::${puppetwebhook::r10k_path}",
      ;
  }
}
