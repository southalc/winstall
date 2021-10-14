# products.rb
# Return a hash of installed packages by leveraging the native puppet provider
#
Facter.add(:products) do
  confine kernel: 'windows'
  setcode do
    packages = {}
    Puppet::Type.type('package').instances.each do |instance|
      # Don't include puppet/ruby gems
      next if instance['provider'].match?(%r{(puppet_)?gem$})
      packages[instance.retrieve_resource.title] = instance.retrieve_resource.to_hash
    end
    packages
  end
end
