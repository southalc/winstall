# frozen_string_literal: true

require 'spec_helper'

describe 'winstall::product' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      ensure: 'installed',
      source: 'https://www.7-zip.org/a/7z1900-x64.msi',
      install_options: ['/qn'],
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge({ products: {} }) }

      it { is_expected.to compile }
    end
  end
end
