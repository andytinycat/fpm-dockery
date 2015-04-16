# Changelog

## 0.1.5

* Update Rubygems when building the builder images. [@lloydpick](https://github.com/lloydpick)
* Allow specifying a private SSH key (with `--private-key`) when packaging, in order to support
  recipes that require cloning a private repository.

## 0.1.4

* Unbreak building on platforms that aren't 'ubuntu'.

## 0.1.3

* Unbreak fpm-dockery binary.

## 0.1.2

* binfiles not properly marked as such in the gemspec.

## 0.1.1

* Add support for fpm-cook's --skip-package option.

## 0.1.0

* Initial version.