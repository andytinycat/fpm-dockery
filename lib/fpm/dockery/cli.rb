require 'optparse'

module FPM
  module Dockery
    class CLI < Clamp::Command
      
      class BaseCommand < Clamp::Command
        include Logging
        include Utils
        
        def valid_builders
          Dir.glob("#{FPM::Dockery.root}/docker/Dockerfile.*").map {|f| File.basename(f.gsub('Dockerfile.', ''))}
        end
        
        def validate_builder!
          unless valid_builders.include?(builder)
            fatal "Image type must be one of: #{valid_builders.join(', ')}"
            exit 1
          end
        end
        
        def create_builder_if_required
          image_check = Subprocess.run("docker images | awk '{print $1}' | grep fpm-dockery/#{builder}")
          unless image_check.exitstatus == 0
            warn "The builder image '#{builder}' does not exist; running the image creation for you"
            create_builder(false)
          end
        end
        
        def create_builder(no_cache)
          validate_builder!
          cache_option = no_cache ? '--no-cache=true' : ''
          exit_status = Subprocess.run("docker build #{cache_option} -f #{FPM::Dockery.root}/docker/Dockerfile.#{builder} -t fpm-dockery/#{builder} #{FPM::Dockery.root}")
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
      
        def execute
          create_builder(no_cache?)
        end
      end
    
      class PackageCommand < BaseCommand
        parameter "RECIPE", "fpm-cookery recipe to build"
        parameter "BUILDER", "Builder to use"
        parameter "[PACKAGE_DIR]", "Where to place the packages created by the build (defaults to /pkg in same dir as recipe)"
        
        def execute
          recipe_path = File.expand_path(recipe)
          dir_to_mount = File.dirname(recipe_path)
          name_of_recipe = File.basename(recipe_path)
          
          validate_builder!
          create_builder_if_required
          
          extra_command = ''
          pkg_dir = "/recipe/pkg"
          
          if package_dir
            extra_command = "-v #{File.expand_path(package_dir)}:/output"
            pkg_dir = "/output"
          end
            
          command = <<eos
docker run \
-v #{dir_to_mount}:/recipe \
#{extra_command} \
fpm-dockery/ubuntu \
--tmp-root /tmp/tmproot \
--pkg-dir #{pkg_dir} \
--cache-dir /tmp/cache \
package \
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