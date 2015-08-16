require 'rake/dsl_definition'

module Dockerhelper
  module Tasks
    extend ::Rake::DSL

    def self.init(config)
      namespace :docker do
        namespace(config.environment) do

          desc 'Print config info'
          task :info do
            puts config.inspect
          end

          desc 'Build docker image'
          task :build do
            config.docker.build(config.dockerfile, tag: config.docker_image)
          end

          desc 'Pull git repo'
          task :pull do
            config.git.clone(config.git_repo_url, config.git_branch)
          end

          desc 'Tag docker image'
          task :repo_tag do
            tag_full = "#{config.docker_repo}:#{config.docker_repo_tag}"
            config.docker.tag(config.docker_image, tag_full)
          end

          desc 'Push docker images to Docker Hub'
          task :push do
            config.docker.push(config.docker_repo, tag: config.docker_repo_tag)
          end

          desc 'Git clone, build image, and push image to Docker Hub'
          task :deploy => [:pull, :build, :repo_tag, :push]

          namespace :kube do
            desc 'Generate replication controller for the current build'
            task :gen_rc do
              config.kubernetes.write_replication_controller
            end

            desc 'Get current replication controller version'
            task :current_rc do
              puts config.kubernetes.current_rc
            end

            desc 'Run replication controller rolling-update'
            task :rolling_update do
              config.kubernetes.rolling_update
            end
          end
        end
      end
    end
  end
end

