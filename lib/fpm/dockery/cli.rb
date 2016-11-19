require 'optparse'

module FPM
  module Dockery
    class CLI < Clamp::Command

      class BaseCommand < Clamp::Command
        include Logging
        include Utils

        # List all valid builders by listing the Dockerfile.* files in
        # the docker directory.
        def valid_builders
          Dir.glob("#{FPM::Dockery.root}/docker/Dockerfile.*").map {|f| File.basename(f.gsub('Dockerfile.', ''))}
        end

        # Check the builder is one we have a Dockerfile for.
        def validate_builder!
          unless valid_builders.include?(builder)
            fatal "Image type must be one of: #{valid_builders.join(', ')}"
            exit 1
          end
        end

        # Create a builder image if it doesn't exist.
        def create_builder_if_required
          image_check = Subprocess.run("docker images | awk '{print $1}' | grep fpm-dockery/#{builder}")
          unless image_check.exitstatus == 0
            warn "The builder image '#{builder}' does not exist; running the image creation for you"
            create_builder(false, [])
          end
        end

        # Create a builder image.
        def create_builder(no_cache, extra_docker_commands)
          validate_builder!
          cache_option = no_cache ? '--no-cache=true' : ''
          exit_status = Subprocess.run("docker build --pull #{extra_docker_commands.join(' ')} #{cache_option} -f #{FPM::Dockery.root}/docker/Dockerfile.#{builder} -t fpm-dockery/#{builder} #{FPM::Dockery.root}")
          if exit_status.exitstatus == 0
            info "Build complete"
          else
            info "Build process exited with a non-zero exit code"
            exit exit_status.exitstatus
          end
        end

      end

      class ListBuildersCommand < BaseCommand
        def execute
          puts valid_builders.join("\n")
        end
      end

      class CreateBuilderImage < BaseCommand
        parameter "BUILDER", "Type of builder image to build"
        option "--no-cache", :flag, "Build without cache"
        option "--docker-params", "DOCKER_PARAMS", "Extra Docker build parameters"

        def execute
          extra_docker_commands = []
          extra_docker_commands << docker_params if docker_params

          create_builder(no_cache?, extra_docker_commands)
        end
      end

      # The package command implementation.
      class PackageCommand < BaseCommand
        parameter "RECIPE", "fpm-cookery recipe to build"
        parameter "BUILDER", "Builder to use"
        parameter "[PACKAGE_DIR]", "Where to place the packages created by the build (defaults to /pkg in same dir as recipe)"
        option "--skip-package", :flag, "Skip package building (identical to fpm-cook --skip-package)"
        option "--private-key", "PRIVATE_KEY", "Private key to use with SSH (for example, when cloning private Git repositories)"
        option "--local-cache-dir", "DIR", "Local cache directory to use (useful if you are working with large source files)"
        option "--docker-params", "DOCKER_PARAMS", "Extra Docker run parameters"

        def execute
          recipe_path = File.expand_path(recipe)
          dir_to_mount = File.dirname(recipe_path)
          name_of_recipe = File.basename(recipe_path)

          validate_builder!
          create_builder_if_required

          extra_docker_commands = []
          extra_fpm_cook_commands = []

          pkg_dir = "/recipe/pkg"

          if package_dir
            extra_docker_commands << "-v #{File.expand_path(package_dir)}:/output"
            pkg_dir = "/output"
          end

          extra_docker_commands << docker_params if docker_params

          if private_key
            begin
              key = IO.read(File.expand_path(private_key))
              if key.include?('ENCRYPTED')
                fatal 'Provided private key has a passphrase ' + private_key
                exit 1
              end
              extra_docker_commands << "-v #{File.expand_path(private_key)}:/root/.ssh/id_rsa"
            rescue Errno::ENOENT
              fatal 'Provided private key does not exist ' + private_key
              exit 1
            end
          end

          if local_cache_dir
            extra_docker_commands << "-v #{File.expand_path(local_cache_dir)}:/tmp/cache"
          end

          if skip_package?
            extra_fpm_cook_commands << "--skip-package"
          end

          command = <<eos
docker run \
-v #{dir_to_mount}:/recipe \
#{extra_docker_commands.join(' ')} \
fpm-dockery/#{builder} \
--tmp-root /tmp/tmproot \
--pkg-dir #{pkg_dir} \
--cache-dir /tmp/cache \
package \
#{extra_fpm_cook_commands.join(' ')} \
/recipe/#{name_of_recipe}
eos
          exit_status = Subprocess.run(command)
          if exit_status.exitstatus == 0
            info "Packaging complete"
          else
            info "Packaging process exited with a non-zero exit code"
            exit exit_status.exitstatus
          end
        end

      end

      subcommand "create-builder-image", "Build one of the fpm-dockery Docker 'builder' images", CreateBuilderImage
      subcommand "package", "Run fpm-cookery in a Docker container to produce a package", PackageCommand
      subcommand "list-builders", "List available builders", ListBuildersCommand

    end
  end
end
