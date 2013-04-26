require 'spec_helper'

describe 'dovecot' do
  context do
    it { should contain_class('dovecot::package').with_ensure('present') }
    it { should contain_class('dovecot::service').with_ensure('running') }
  end

  context '(with ensure latest)' do
    let(:params) {{ensure: 'latest'}}
    it { should contain_class('dovecot::package').with_ensure('latest') }
  end
end
