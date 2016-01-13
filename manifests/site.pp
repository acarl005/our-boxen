require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

# Set the global default node (auto-installs it if it can)
class { 'nodejs::global':
  version => '4.2.1'
}

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # ensure a npm module is installed for a certain node version
  # note, you can't have duplicate resource names so you have to name like so
  npm_module { "bower for 4.2.1":
    module       => 'bower',
    version      => '~> 1.4.1',
    node_version => "4.2.1",
  }

  # ensure a module is installed for all node versions
  npm_module { 'bower for all nodes':
    module       => 'bower',
    version      => '~> 1.4.1',
    node_version => '*',
  }


  # Installing nodenv plugin
  nodejs::nodenv::plugin { 'nodenv-vars':
    ensure => 'ee42cd9db3f3fca2a77862ae05a410947c33ba09',
    source  => 'OiNutter/nodenv-vars'
  }


  # node versions
  # nodejs::version { '0.12': }
  # nodejs::version { '4.2.1': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # Other stuff
  include sublime_text_2
  sublime_text_2::package { 'Emmet':
    source => 'sergeche/emmet-sublime'
  }

  include chrome
  include iterm2::stable
  include atom

  # install the linter package
  atom::package { 'linter': }

  # install the monokai theme
  atom::theme { 'monokai': }

}


class config::sublime {

  define addpkg {
    $packagedir = "/Library/Application Support/Sublime Text 2/Packages/"
    $pkgarray = split($name, '[/]')
    $pkgname = $pkgarray[1]

    exec { "git clone https://github.com/${name}.git":
      cwd      => "/Users/${::luser}${packagedir}",
      provider => 'shell',
      creates  => "/Users/${::luser}${packagedir}${pkgname}",
      path     => "${boxen::config::homebrewdir}/bin",
      require  => [Package['SublimeText2'], Class['git']],
    }
  }

  $base = "/Users/${::luser}/Library/Application Support"
  $structure = [ "${base}/Sublime Text 2", "${base}/Sublime Text 2/Packages" ]

  file { $structure:
    ensure  => 'directory',
    owner   => "${::luser}",
    mode    => '0755',
  }->

  file { "${boxen::config::bindir}/subl":
    ensure  => link,
    target  => '/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl',
    mode    => '0755',
    require => Package['SublimeText2'],
  }->

  file { "${base}/Sublime Text 2/Packages/User/Default (OSX).sublime-keymap":
    content  => '[{ "keys": ["super+ctrl+r"], "command": "reveal_in_side_bar"}]',
  }->

  file { "${base}/Sublime Text 2/Packages/User/Preferences.sublime-settings":
      content  => '
{
"trim_trailing_white_space_on_save": true,
"tab_size": 2,
"translate_tabs_to_spaces": true,
"save_on_focus_lost": true
}'
  }

  addpkg { [
    "jisaacks/GitGutter",
    "revolunet/sublimetext-markdown-preview",
    "SublimeColors/Solarized",
    "wbond/sublime_package_control",
    "eklein/sublime-text-puppet",
    "sergeche/emmet-sublime"
    ]:
  }

}
