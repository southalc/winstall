# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`winstall`](#winstall): A class for installing Windows packages from various sources

### Defined types

* [`winstall::product`](#winstallproduct): A defined type for installing Windows software products

## Classes

### `winstall`

Enables installation of Windows software products from local, UNC (MSI packages
only), or URL paths.  When a URL is used, a local copy is downloaded, installed,
and the installer file deleted.

#### Examples

##### 

```puppet
include winstall
```

#### Parameters

The following parameters are available in the `winstall` class.

##### `products`

Data type: `Hash`

Hash
A hash of products to be installed.  See the `products` defined type documentation.

Default value: `{}`

## Defined types

### `winstall::product`

Enable Windows software installation from local, network, or URL sources.
When using this defined type, ensure the resource title matches the
`DisplayName` of the product being installed to prevent Windows from
re-installing with every Puppet run.

Ref: https://puppet.com/docs/puppet/latest/resources_package_windows.html

#### Examples

##### Install 7-zip, where the version is included in the title

```puppet
winstall::product { '7-Zip 19.00 (x64)':
  ensure          => 'installed',
  source          => 'https://www.7-zip.org/a/7z1900-x64.msi',
  install_options => ['/qn'],
}
```

#### Parameters

The following parameters are available in the `winstall::product` defined type.

##### `ensure`

Data type: `String`

String
Valid options are `installed`, `absent`, or `<version>` that represents the
specific version of the product that must be installed.

Default value: `'installed'`

##### `source`

Data type: `String`

String
Source path to the installation package.  This can be a local or network
drive, a UNC path for MSI packages, or a URL to the package file.  When the
source to be installed is a URL it will be downloaded to a a temporary file,
installed, and the temporary file removed.

##### `tmp_file`

Data type: `String`

String
Optional temporary file for staging installer files when the `source`
is a URL without a "friendly" file name.  By default, the `source` URL is
split on the forward slash and the last segment is used as the temp file.

Default value: `''`

##### `tmp_dir`

Data type: `String`

String
Optional temporary directory for staging installer files when the `source`
is a URL.  If defined, the directory must already exist.

Default value: `''`

##### `install_options`

Data type: `Array`

Array
Optional array of command arguments to be used by the installer.  These are often unique per application.

Default value: `[]`

##### `uninstall_options`

Data type: `Array`

Array
Optional array of command arguments to be used by the uninstaller.  These are often unique per application.

Default value: `[]`

