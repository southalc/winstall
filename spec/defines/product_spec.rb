# frozen_string_literal: true

require 'spec_helper'

describe 'winstall::product' do
  let(:title) { '7-Zip 19.00 (x64 edition)' }

  on_supported_os.each do |os, os_facts|
    context "install product on #{os}" do
      let(:facts) { os_facts.merge({ products: {} }) }
      let(:params) do
        {
          ensure: 'installed',
          source: 'https://www.7-zip.org/a/7z1900-x64.msi',
          install_options: ['/qn'],
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_archive('7-Zip 19.00 (x64 edition)').with(
          {
            'ensure'          => 'present',
            'source'          => 'https://www.7-zip.org/a/7z1900-x64.msi',
            'path'            => 'C:\\Windows\\Temp\\7z1900-x64.msi',
            'creates'         => 'C:\\Windows\\Temp\\7z1900-x64.msi',
            'cleanup'         => false,
            'extract'         => false,
          },
        )
        is_expected.to contain_package('7-Zip 19.00 (x64 edition)').with(
          {
            'ensure'          => 'installed',
            'source'          => 'C:\\Windows\\Temp\\7z1900-x64.msi',
            'install_options' => ['/qn'],
          },
        )
        is_expected.to contain_file('C:\\Windows\\Temp\\7z1900-x64.msi').with(
          {
            'ensure' => 'absent',
          },
        )
      end
    end

    context "remove installed product on #{os}" do
      let(:facts) do
        os_facts.merge(
          {
            products: {
              '7-Zip 19.00 (x64 edition)': {
                'ensure'   => '19.00.00.0',
                'provider' => 'windows',
              }
            }
          },
        )
      end
      let(:params) do
        {
          ensure: 'absent',
          source: 'https://www.7-zip.org/a/7z1900-x64.msi',
          install_options: ['/qn'],
        }
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_package('7-Zip 19.00 (x64 edition)').with(
          {
            'ensure' => 'absent',
          },
        )
      end
    end
  end
end
