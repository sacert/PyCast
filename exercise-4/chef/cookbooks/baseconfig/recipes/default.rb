# Make sure the Apt package lists are up to date, so we're downloading versions that exist.
cookbook_file "apt-sources.list" do
  path "/etc/apt/sources.list"
end
execute 'apt_update' do
  command 'apt-get update'
end

# Base configuration recipe in Chef.
package "wget"
package "ntp"

cookbook_file "ntp.conf" do
  path "/etc/ntp.conf"
end
execute 'ntp_restart' do
  command 'service ntp restart'
end

package “ruby-dev”
package “sqlite3”
package “libsqlite3-dev”
package “zliblg-dev”
package “nodejs”

execute ‘bundler install’ do
   command ‘gem install bundler —-conservative’
end

execute ‘bundle’ do
   command ‘bundle install’
   cwd ‘/home/vagrant/project/blog’
   user ‘vagrant’
end

execute ‘migrate’ do
   command ‘rake db:migrate’
   cwd ‘/home/vagrant/project/blog’
   user ‘vagrant’
end

execute ‘migrate’ do
   command ‘rails server —d -b 0.0.0.0’
   cwd ‘/home/vagrant/project/blog’
   user ‘vagrant’
end
