require 'git'
require 'yaml'
require 'semantic'
require 'securerandom'
require 'rake_terraform'
require 'rake_circle_ci'
require 'rake_github'
require 'rake_ssh'
require 'rspec/core/rake_task'

require_relative 'lib/configuration'
require_relative 'lib/version'

configuration = Configuration.new

def repo
  Git.open('.')
end

def latest_tag
  repo.tags.map do |tag|
    Semantic::Version.new(tag.name)
  end.max
end

task :default => 'test:integration'

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.12.17')

RakeSSH.define_key_tasks(
    namespace: :deploy_key,
    path: 'config/secrets/ci/',
    comment: 'maintainers@infrablocks.io'
)

RakeCircleCI.define_project_tasks(
    namespace: :circle_ci,
    project_slug: 'github/infrablocks/terraform-aws-ecr-repository'
) do |t|
  circle_ci_config =
      YAML.load_file('config/secrets/circle_ci/config.yaml')

  t.api_token = circle_ci_config["circle_ci_api_token"]
  t.environment_variables = {
      ENCRYPTION_PASSPHRASE:
          File.read('config/secrets/ci/encryption.passphrase')
              .chomp
  }
  t.ssh_keys = [
      {
          hostname: "github.com",
          private_key: File.read('config/secrets/ci/ssh.private')
      }
  ]
end

RakeGithub.define_repository_tasks(
    namespace: :github,
    repository: 'infrablocks/terraform-aws-ecr-repository',
) do |t|
  github_config =
      YAML.load_file('config/secrets/github/config.yaml')

  t.access_token = github_config["github_personal_access_token"]
  t.deploy_keys = [
      {
          title: 'CircleCI',
          public_key: File.read('config/secrets/ci/ssh.public')
      }
  ]
end

namespace :pipeline do
  task :prepare => [
      :'circle_ci:env_vars:ensure',
      :'circle_ci:ssh_keys:ensure',
      :'github:deploy_keys:ensure'
  ]
end

namespace :test do
  RSpec::Core::RakeTask.new(:integration => ['terraform:ensure']) do
    ENV['AWS_REGION'] = 'eu-west-2'
    ENV['TF_PLUGIN_CACHE_DIR'] =
        "#{Paths.project_root_directory}/vendor/terraform/plugins"
  end
end

namespace :deployment do
  namespace :prerequisites do
    RakeTerraform.define_command_tasks do |t|
      t.argument_names = [:deployment_identifier]

      t.configuration_name = 'prerequisites'
      t.source_directory =
          configuration.for(:prerequisites).source_directory
      t.work_directory =
          configuration.for(:prerequisites).work_directory

      t.state_file =
          configuration.for(:prerequisites).state_file

      t.vars = lambda do |args|
        configuration.for(:prerequisites, args)
            .vars
            .to_h
      end
    end
  end

  namespace :harness do
    RakeTerraform.define_command_tasks do |t|
      t.argument_names = [:deployment_identifier]

      t.configuration_name = 'harness'
      t.source_directory = configuration.for(:harness).source_directory
      t.work_directory = configuration.for(:harness).work_directory

      t.state_file = configuration.for(:harness).state_file

      t.vars = lambda do |args|
        configuration.for(:harness, args)
            .vars
            .to_h
      end
    end
  end
end

namespace :version do
  task :bump, [:type] do |_, args|
    next_tag = latest_tag.send("#{args.type}!")
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
    puts "Bumped version to #{next_tag}."
  end

  task :release do
    next_tag = latest_tag.release!
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
    puts "Released version #{next_tag}."
  end
end
