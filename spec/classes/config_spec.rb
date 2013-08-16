require 'spec_helper'

describe 'dovecot::config' do
  context do
    it 'creates dovecot.conf' do
      should contain_file('/etc/dovecot/dovecot.conf').with({
        ensure: 'present',
        owner: 'root',
        group: 'dovecot',
        mode: '0644',
        require: 'Class[Dovecot::Package]',
        notify: 'Class[Dovecot::Service]'
      }).with_content(%r{^protocols =.*\bimap\b}).
         with_content(%r{^protocols =.*\bpop3\b})
    end
  end

  context 'SQL auth setup' do
    let(:params) {{
      sql: true,
      dbdriver: 'mysql',
      dbhost: 'dbhost',
      dbname: 'dbname',
      dbuser: 'dbuser',
      dbpass: 'dbpass',
      pass_scheme: 'PASS-SCHEME',
      virtual_homes: '/virtual/home/dir',
      virtual_uid: 100,
      virtual_gid: 200,
      users_table: 'utable',
      users_user: 'uuser',
      users_domain: 'udomain',
      users_password: 'upasswd',
      domains_table: 'dtable',
      domains_domain: 'ddomain',
      domains_services: 'dservices'
    }}

    it 'creates dovecot.conf with SQL auth' do
      should contain_file('/etc/dovecot/dovecot.conf').
        with_content(%r{^passdb \{\s+driver = sql\s+args = /etc/dovecot/dovecot-sql.conf\s+\}}m).
        with_content(%r{^userdb \{\s+driver = static\s+args = uid=100 gid=200 home=/virtual/home/dir mail=maildir:~/%d/%n/ allow_all_users=yes\s+\}}m)
    end

    it 'creates dovecot-sql.conf' do
      should contain_file('/etc/dovecot/dovecot-sql.conf').with({
        ensure: 'present',
        owner: 'root',
        group: 'dovecot',
        mode: '0640',
        require: 'Class[Dovecot::Package]',
        notify: 'Class[Dovecot::Service]'
      }).
        with_content(<<EnD)
driver = mysql
connect = host=dbhost dbname=dbname user=dbuser password=dbpass
default_pass_scheme = PASS-SCHEME

password_query = \\
  SELECT \\
    utable.uuser AS username, \\
    utable.udomain AS domain, \\
    utable.upasswd AS password \\
  FROM utable, dtable \\
 WHERE dtable.ddomain = '%d' \\
   AND utable.udomain = '%d' \\
   AND utable.uuser = '%n' \\
   AND dtable.dservices LIKE '%%:%Ls%Lc:%%'
EnD
    end
  end

  context 'PAM auth setup' do
    let(:params) {{pam: true}}
    it 'creates dovecot.conf with PAM auth' do
      should contain_file('/etc/dovecot/dovecot.conf').
        with_content(%r{^passdb \{\s+driver = pam\s+\}}m).
        with_content(%r{^userdb \{\s+driver = passwd\s+\}}m)
    end
  end

  context 'SASL provider setup' do
    let(:params) {{sasl: true, virtual_user: 'virtuser', virtual_group: 'virtgroup'}}
    it 'creates dovecot.conf with SASL service for Postfix' do
      should contain_file('/etc/dovecot/dovecot.conf').
        with_content(
          %r{^service\sauth\s\{\s+
            unix_listener\sauth-userdb\s\{\s+
              group\s+=\s+virtgroup\s+
              mode\s+=\s+0660\s+
              user\s+=\s+virtuser\s+
            \}\s+
            unix_listener\s/var/spool/postfix/private/auth\s\{\s+
              group\s+=\s+postfix\s+
              mode\s+=\s+0660\s+
              user\s+=\s+postfix\s+
            \}\s+
            user\s+=\s+root\s+
          \}}mx)
    end
  end

  context 'SSL setup' do
    let(:params) {{ssl: 'dovecot'}}
    it 'creates dovecot.conf with SSL setup' do
      should contain_file('/etc/dovecot/dovecot.conf').
        with_content(%r{^ssl_cert = </etc/ssl/certs/dovecot.pem$}).
        with_content(%r{^ssl_key = </etc/ssl/private/dovecot.key$})
    end
  end
end
