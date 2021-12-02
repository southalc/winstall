# @summary A class for installing Windows packages from various sources
#
# Enables installation of Windows software products from local, UNC (MSI packages
# only), or URL paths.  When a URL is used, a local copy is downloaded, installed,
# and the installer file deleted.
#
# @param products Hash
#   A hash of products to be installed.  See the `products` defined type documentation.
#
# @example
#   include winstall
#
class winstall(
  Hash $products = {},
){
  if $::facts['kernel'] == 'windows' {
    $products.each |$name, $properties| {
      Resource['Winstall::Product'] { $name:
        * => $properties,
      }
    }
  }
}
