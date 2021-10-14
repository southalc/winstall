# winstall

## Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Facts](#facts)
1. [Limitations](#limitations)
1. [Development](#development)

## Description

This Puppet module enables installing Windows packages from different sources,
allowing installation directly from a URL in addition to local or UNC paths.
The module accepts a hash of 'products' that defines the applications to be
installed and iterates through them using the 'winstall::product' defined type.

When a URL is used as the source, a copy of the source is downloaded to a temp
file, installed, and the downloaded installer is deleted.

## Usage

Including the module in an environment does nothing by default.  You must invoke the class
with a `products` hash, define `winstall::products` in hiera, or use the defined type
`winstall::product` directly in a manifest to manage Windows software products.

Controlling versions and upgrades depends on whether or not the package contains a proper
version attribute.  See the Puppet documentation for more details on using
[package resources on Windows](https://puppet.com/docs/puppet/latest/resources_package_windows.html).

Generally, to install an exact version, the `ensure` parameter of the `product` defined
type should be set to the target version.  To just make sure the product is installed,
but perhaps allow clients to upgrade versions beyond the initially assigned package, set
the value of `ensure` to 'installed'.

This hiera example data would install 7-Zip on the targeted node:
```
winstall::products:
  '7-Zip 19.00 (x64)':
    ensure: 'installed'
    source: 'https://www.7-zip.org/a/7z1900-x64.msi'
    install_options:
      - '/S'
```
This example is a hiera based role I assign to Windows 10 clients used for development.
The role installs several products from packages, ensures OneDrive is removed, installs
PowerCLI PowerShell modules, and sets `GIT_SSH` as a global environment variable so Visual
Studio Code can use SSH keys loaded into the PuTTY agent.
```
---
# Windows 10 dev tools - Requires the following modules in the environment
#----(Puppetfile format)-------------
# mod 'puppetlabs/pwshlib', :latest
# mod 'puppetlabs-powershell', :latest
# mod 'puppetlabs-registry', :latest
# mod 'puppet/archive', :latest
# mod 'southalc/types', :latest
# mod 'southalc/winstall', :latest
#------------------------------------

classes:
  - types
  - winstall

types::types:
  - registry_key
  - registry_value

winstall::products:
  'Microsoft OneDrive':
    ensure: absent
    source: '%WINDIR%\WinSxS\wow64_microsoft-windows-onedrive-setup_*\OneDriveSetup.exe'
  '7-Zip 19.00 (x64)':
    ensure: installed
    source: 'https://my.local.server/pub/software/7z1900-x64.exe'
    install_options:
      - '/S'
  'VMware Remote Console':
    ensure: installed
    source: 'https://my.local.server/pub/software/VMware-VMRC-12.0.1-18113358.exe'
    install_options:
      - '/s'
      - '/v'
      - '/qn'
      - 'EULAS_AGREED=1'
      - 'AUTOSOFTWAREUPDATE=1'
      - 'DATACOLLECTION=0'
  'PuTTY release 0.76 (64-bit)':
    ensure: installed
    source: 'https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.76-installer.msi'
    install_options:
      - '/qn'
  'Git':
    ensure: '2.33.1'
    source: 'https://github.com/git-for-windows/git/releases/download/v2.33.1.windows.1/Git-2.33.1-64-bit.exe'
    install_options:
      - '/VERYSILENT'
      - '/NORESTART'
  'Microsoft Visual Studio Code':
    ensure: installed
    source: 'https://my.local.server/pub/software/VSCodeSetup-x64-1.47.2.exe'
    install_options:
      - '/VERYSILENT'
      - '/NORESTART'
      - '/MERGETASKS=!runcode'


types::exec:
  install_powerCLI:
    provider: 'powershell'
    command: |
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
      Install-Module -Name VMware.PowerCLI -Confirm:$false
      Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
    unless: Get-InstalledModule VMware.PowerCLI -ErrorAction Stop
    require:
      - 'Registry_value[HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ExecutionPolicy]'
  install_powershell_PackageManagement:
    provider: 'powershell'
    command: |
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope AllUsers -AllowClobber
    unless: (Get-InstalledModule -Name PackageManagement -ErrorAction Stop).Version -ge 1.4.6


# Ensure keys exist before trying to manage values
types::registry_key:
  'HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell':
    ensure: present
  'HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive':
    ensure: present

types::registry_value:
  # Enable Visual Studio code to use SSH keys loaded into pageant
  'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\GIT_SSH':
    ensure: present
    type: string
    data: 'C:\Program Files\PuTTY\plink.exe'
  # Globally manage PowerShell execution policy
  'HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ExecutionPolicy':
    ensure: present
    type: string
    data: RemoteSigned
    require:
      - 'Registry_key[HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell]'
  # Disables OneDrive
  'HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive\DisableFileSyncNGSC':
    ensure: present
    type: string
    data: '1'
    require:
      - 'Registry_key[HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive]'
```

## Facts

When installing packages from a URL, we need to have an inventory of installed software
in order to determine if an assigned package should be downloaded and installed.  The
module includes the custom fact `products` that abuses the native Puppet provider to
return a hash of installed software products with the current version.  This fact is
similar to what is returned by running `puppet resource package`.

## Limitations

This module is for Windows only, and should work with all Windows versions.  The
[archive module](https://forge.puppet.com/puppet/archive) is requied when using
URLs as the source for a product.

## Development

To contribute, fork the source and submit a pull request.


