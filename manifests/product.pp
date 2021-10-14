# @summary A defined type for installing Windows software products
#
# Enable Windows software installation from local, network, or URL sources.
# When using this defined type, ensure the resource title matches the
# `DisplayName` of the product being installed to prevent Windows from
# re-installing with every Puppet run.
#
# Ref: https://puppet.com/docs/puppet/latest/resources_package_windows.html
#
# @param ensure String
#   Valid options are `installed`, `absent`, or `<version>` that represents the
#   specific version of the product that must be installed.
# 
# @param source String
#   Source path to the installation package.  This can be a local or network
#   drive, a UNC path for MSI packages, or a URL to the package file.  When the
#   source to be installed is a URL it will be downloaded to a a temporary file,
#   installed, and the temporary file removed.
#
# @param tmp_file String
#   Optional temporary file for staging installer files when the `source`
#   is a URL without a "friendly" file name.  By default, the `source` URL is
#   split on the forward slash and the last segment is used as the temp file.
#
# @param tmp_dir String
#   Optional temporary directory for staging installer files when the `source`
#   is a URL.  If defined, the directory must already exist.
#
# @param install_options Array
#   Optional array of command arguments to be used by the installer.  These are often unique per application.
#
# @param uninstall_options Array
#   Optional array of command arguments to be used by the uninstaller.  These are often unique per application.
#   
# @example Install 7-zip, where the version is included in the title
#   winstall::product { '7-Zip 19.00 (x64)':
#     ensure          => 'installed',
#     source          => 'https://www.7-zip.org/a/7z1900-x64.msi',
#     install_options => ['/qn'],
#   }
#
define winstall::product (
  String $source,
  String $ensure           = 'installed',
  String $tmp_dir          = '',
  String $tmp_file         = '',
  Array $install_options   = [],
  Array $uninstall_options = [],
){
  unless $::facts['kernel'] == 'windows' {
    fail("'winstall::product' is only for Windows systems")
  }

  # Setup a temp file if $source is a URL
  if $source =~ /^http(s)?:.+/ {
    $source_is_url = true
    if $tmp_file == '' {
      $file_name = split($source, '/')[-1]
    } else {
      $file_name = $tmp_file
    }
    if $tmp_dir == '' {
      $windows_temp = regsubst($::facts['os']['windows']['system32'], /system32/, 'Temp')
      $installer = "${windows_temp}\\${file_name}"
    } else {
      $installer = "${windows_temp}\\${file_name}"
    }
  } else {
    $installer = $source
  }

  if $ensure == 'absent' {
    Package { $title:
      ensure            => 'absent',
      uninstall_options => $uninstall_options,
    }
  } else {
    # Install only when not specified version is not already present, or when
    # the installed version does not match the resource declaration
    if ! has_key($facts['products'], $title) or
      (($ensure != 'installed') and ($ensure != $facts['products'][$title]['ensure'])) {

      if $source_is_url {
        # Use archive module to download to local $installer file
        Archive { $title:
          ensure  => 'present',
          source  => $source,
          path    => $installer,
          creates => $installer,
          cleanup => false,
          extract => false,
        }
        # Delete the temporary file used for the installation
        File { $installer:
          ensure => 'absent',
        }
        # Ensure resources are created in the correct order
        Archive[$title] -> Package[$title] -> File[$installer]
      }
      # When $source is not a URL just install directly
      Package { $title:
        ensure          => $ensure,
        source          => $installer,
        install_options => $install_options,
      }
    }
  }
}
