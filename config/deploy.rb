# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'fc2search'
set :repo_url, 'git@github.com:quotto/fc2search.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/project/fc2search'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_ruby, '2.1.2'

set :default_env, {
  rbenv_root: "#{fetch(:rbenv_path)}",
  path: "#{fetch :rbenv_path}/shims:#{fetch :rbenv_path}/bin:#{fetch :rbenv_path}/versions/2.1.2/lib/ruby/gems/2.1.0/gems/passenger-5.0.26/bin:$PATH"
}

set :bundle_without, [:development]
namespace :deploy do

  desc 'Delete assets'
  task :clear_assets do
    on roles(:app),in: :sequence, wait: 5 do
      execute :rm, "-rf shared/public/assets"
    end
  end
  after :starting, :clear_assets
    
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute "passenger-config", "restart-app --name #{fetch :deploy_to}/current"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:app), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
