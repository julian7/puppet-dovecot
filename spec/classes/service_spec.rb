require 'spec_helper'

describe 'dovecot::service' do
  context do
    it 'makes sure it is running' do
      should contain_service('dovecot').with(
        ensure: 'running',
        hasstatus: true,
        hasrestart: true,
        enable: true,
        require: ['Class[Dovecot::Package]', 'Class[Dovecot::Config]']
      )
    end
  end
end
