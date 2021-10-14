# frozen_string_literal: true

require 'spec_helper'

describe 'winstall' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          products: {
            '7-Zip 21.03 (x64)': {
              ensure: 'installed',
              source: 'https://www.7-zip.org/a/7z2103-x64.msi',
              install_options: ['/S'],
            }
          }
        }
      end

      it { is_expected.to compile }
    end
  end
end
