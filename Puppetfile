# This file manages Puppet module dependencies.
#
# It works a lot like Bundler. We provide some core modules by
# default. This ensures at least the ability to construct a basic
# environment.

# Shortcut for a module from GitHub's boxen organization
def github(name, *args)
  options ||= if args.last.is_a? Hash
    args.last
  else
    {}
  end

  if path = options.delete(:path)
    mod name, :path => path
  else
    version = args.first
    options[:repo] ||= "boxen/puppet-#{name}"
    mod name, version, :github_tarball => options[:repo]
  end
end

# Shortcut for a module under development
def dev(name, *args)
  mod "puppet-#{name}", :path => "#{ENV['HOME']}/src/boxen/puppet-#{name}"
end

# Includes many of our custom types and providers, as well as global
# config. Required.

github "boxen", "3.11.0"

# Support for default hiera data in modules

github "module_data", "0.0.4", :repo => "ripienaar/puppet-module-data"

# Core modules for a basic development environment. You can replace
# some/most of these if you want, but it's not recommended.

github "brewcask",    "0.0.6"
github "dnsmasq",     "2.0.1"
github "foreman",     "1.2.0"
github "gcc",         "3.0.2"
github "git",         "2.7.92"
github "go",          "2.1.0"
github "homebrew",    "1.13.0"
github "hub",         "1.4.1"
github "inifile",     "1.4.1", :repo => "puppetlabs/puppetlabs-inifile"
github "nginx",       "1.4.6"
# github "nodejs",      "5.0.0"
github "openssl",     "1.0.0"
github "phantomjs",   "3.0.0"
github "pkgconfig",   "1.0.0"
github "repository",  "2.4.1"
github "ruby",        "8.5.2"
github "stdlib",      "4.7.0", :repo => "puppetlabs/puppetlabs-stdlib"
github "sudo",        "1.0.0"
github "xquartz",     "1.2.1"

# Set the global default node (auto-installs it if it can)
class { 'nodejs::global':
  version => '4.1.1'
}

# ensure a npm module is installed for a certain node version
# note, you can't have duplicate resource names so you have to name like so
$version = "4.1.1"
npm_module { "bower for ${version}":
  module       => 'bower',
  version      => '~> 1.4.1',
  node_version => $version,
}

# ensure a module is installed for all node versions
npm_module { 'bower for all nodes':
  module       => 'bower',
  version      => '~> 1.4.1',
  node_version => '*',
}

# install a node version
nodejs::version { '4.1.1': }

# Installing nodenv plugin
nodejs::nodenv::plugin { 'nodenv-vars':
  ensure => 'ee42cd9db3f3fca2a77862ae05a410947c33ba09',
  source  => 'OiNutter/nodenv-vars'
}

# Optional/custom modules. There are tons available at
# https://github.com/boxen.
# github "elasticsearch", "2.8.0"
# github "mysql",         "2.0.1"
github "postgresql",  "4.0.1"
# github "redis",       "3.1.0"
# github "sysctl",      "1.0.1"


# Other stuff
include sublime_text_2
sublime_text_2::package { 'Emmet':
  source => 'sergeche/emmet-sublime'
}

include mongodb
include chrome
include iterm2::stable
include atom

# install the linter package
atom::package { 'linter': }

# install the monokai theme
atom::theme { 'monokai': }



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
