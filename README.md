# fpm-dockery

Build [fpm-cookery](https://github.com/bernd/fpm-cookery) recipes with Docker!

## What is this?

This is a terribly-named wrapper around [fpm-cookery](https://github.com/bernd/fpm-cookery)
that allows you to run fpm-cookery builds inside a container. I wrote this to allow me to run package builds
in development on my laptop in the same way that Jenkins runs them, and to allow easy building of packages
for a variety of Linux distributions.

## Why would you use this?

If you are building your own operating system packages, you should be running them in a clean
environment every time. fpm-cookery is a superb tool for expressing the process of building and packaging
using fpm, but it provides no real functionality for working in a clean environment.

With the advent of [Docker](https://www.docker.com/), it is fast and easy to bring up an isolated
environment (a container) to perform the package building in. It also allows your CI server to perform
a very simple invocation to build packages (`fpm-dockery build recipe.rb ubuntu12.04`), and allows you
to run the same build on your development machine in the same way.

If a build fails, you can easily re-run the container and be dropped into the state where the build failed.
This makes it very easy to troubleshoot why a build is failing.

## How does it work?

`fpm-dockery` has the notion of 'builder' images. These are specially prepared Docker images that
contain enough tooling to get `fpm-cookery` working, along with `fpm-cookery` itself.

You can see the Dockerfiles used to generate these images in the
[`docker` directory](https://github.com/andytinycat/fpm-dockery/tree/master/docker) of this
repository.

__NOTE: if you'd like to see more distributions supported, please contribute a Dockerfile in
a pull request - it will be welcomed! I went with what I know and use, but Centos/Fedora support should
be fairly trivial.__

These 'builder' images launch `fpm-cook` with specifically-crafted arguments to ensure a clean
build each time - and each build takes place in a new container created from the 'builder' image.

The containers launch with two volumes attached - one volume is the directory containing the recipe,
and the other volume is the output directory for the packages. The arguments supplied to `fpm-cook`
ensure packages are placed in the correct location.

## Limitations

The following limitations are imposed on recipes you use with `fpm-dockery`:

  * Docker 1.5 or later is required, as we make use of the `-f` flag with
    `docker build`.
  * If a recipe includes external files, these files must be in the same directory
    as the recipe file, or any number of subdirectories below where the recipe file is located.
    This is because the directory containing the recipe is mounted inside the Docker container
    when a build occurs, so files in this directory or lower can be referenced.
  * Since we're using Docker, we can only run builds on Linux distributions.

## Installation

fpm-dockery is distributed as a Rubygem:

`gem install fpm-dockery`

Once you've installed it, you will have access to the `fpm-dockery` command line tool.

## Usage

`fpm-dockery` has command line documentation, accessible by supplying the `--help argument`:

    $ bin/fpm-dockery --help
    Usage:
        fpm-dockery [OPTIONS] SUBCOMMAND [ARG] ...

    Parameters:
        SUBCOMMAND                    subcommand
        [ARG] ...                     subcommand arguments

    Subcommands:
        create-builder-image          Build one of the fpm-dockery Docker 'builder' images
        package                       Run fpm-cookery in a Docker container to produce a package
        list-builders                 List available builders

    Options:
        -h, --help                    print help

### Building packages

To create a package, run `fpm-dockery package`, which takes two required arguments and one
optional argument:

    fpm-dockery package PATH_TO_RECIPE BUILDER [PACKAGE_DIR]

The builder is one of the supported builder images. If the builder image does not exist on the
system where Docker is running, it will be automatically created first. The packages will be
created in `PATH_TO_RECIPE/pkg`.

For example, to run the supplied example recipe (which builds Redis) on Ubuntu Precise (12.04 LTS), run:

    fpm-dockery package example_recipe/recipe.rb ubuntu12.04

If you'd like to override where packages are created, you can specify the optional third
argument `PACKAGE_DIR`:

    fpm-dockery package example_recipe/recipe.rb ubuntu12.04 /tmp/somedir

If you're building a package from git source, and you're using a private repository
(on GitHub or BitBucket or wherever), you can supply an SSH private key to build with.
The private key __must have no passphrase__. For reasons of security, it would be wise
to create a keypair just for your package builds, and give it only read access to the repository.

    fpm-dockery package --private-key some/path/builder-private-key example_recipe/recipe.rb ubuntu12.04

If you're working with large source files and don't want to re-download the source each time you can specify a local cache directory which fpm-cookery will use.

    fpm-dockery package --local-cache-dir some/path example_recipe/recipe.rb ubuntu12.04

If you'd like to make fpm-cookery skip the packaging step, supply the `--skip-package` option:

    fpm-dockery package --skip-package example_recipe/recipe.rb ubuntu12.04

If you'd like to supply more docker run parameters, for example environment variables, supply the `--docker-params` option:

    fpm-dockery package --docker-params "-e PKG_VER=2.0" example_recipe/recipe.rb ubuntu12.04



### Viewing available builders

To see the available builders, run:

    fpm-dockery list-builders

### Manually creating builder images

If you'd like to run a builder image creation task manually, you can run:

    fpm-dockery create-builder-image BUILDER

For example, to build the Ubuntu Trusty (14.04 LTS) builder image, run:

    fpm-dockery create-builder-image ubuntu14.04

If you want to run this image creation without the Docker cache (perhaps your image is somehow
messed up), run:

    fpm-dockery create-builder-image --no-cache BUILDER

For example, to run the Trusty build again with no cache:

    fpm-dockery create-builder-image --no-cache ubuntu14.04

## Contributing

Pull requests are welcomed, especially for supporting new distributions. This project was a spike to replace
some unpleasant homegrown scripts at [Forward3D](https://github.com/forward3d), so it's immature. Bugfixes and features welcomed.

1. Fork it ( https://github.com/[my-github-username]/fpm-dockery/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknowledgements

Thanks to [@bernd](https://github.com/bernd) for creating fpm-cookery, and [@sissel](https://github.com/jordansissel)
for creating FPM, without which life would be less pleasant.

I also used the Redis example recipe from @bernd's repository and placed it in this repository so it can be used
for a quick proof-of-concept.
