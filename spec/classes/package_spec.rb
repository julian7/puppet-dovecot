require 'spec_helper'

describe 'dovecot::package' do
  def contains_packages(version)
    %w[common imapd pop3d mysql].each do |name|
      should contain_package("dovecot-#{name}").with_ensure(version)
    end
  end

  context do
    it 'has packages' do
      contains_packages('present')
    end
  end

  context '(with ensure => latest)' do
    let(:params) {{ensure: 'latest'}}

    it 'has latest packages' do
      contains_packages('latest')
    end
  end
end
