# Docker Image for MariaDB on Ubuntu 20.04 (Focal Fossa)

**Maintained by: [raasss](https://github.com/raasss/)**

### How do I use this docker image?

See [the Docker Hub page](https://hub.docker.com/repository/docker/raasss/mariadb-ubuntu-20.04/general) or [GitHub page](https://github.com/raasss/docker-mariadb-ubuntu-20.04/blob/main/README.docker.io.md) for the full README on how to use this container image.

## Reporting a Bug / Feature Request

If you run into any bugs or have ideas on new features you can file bug reports and feature requests on the [GitHub Issues](https://github.com/raasss/docker-mariadb-ubuntu-20.04/issues).

## Contributing a Bug Fix / Feature Request

Contributing changes or feauters involves [creating a pull request](https://github.com/raasss/docker-mariadb-ubuntu-20.04/pulls).

The development of the container image here aims to provide complete backwards compatibility for existing users. If there is a case where the container previously started and behaved in a certain way, after your change, it should, under the same circumstances, behave in the same way.

Changes to the Dockerfile should be done at the branch level `Dockerfile` and entrypoint changes in `docker-entrypoint.sh`. Please consider having those changes applied to other branches, for other versions, too.

### Coding Conventions

Please write code in a similar style to what is already there. Use tab indents on the entrypoint script.

### Testing Changes

To build, you can use `make build`. It will use `docker buildx` so be sure it's available on your side.

Run:
```
make build
```

This will build docker images for all configured platforms.

### Git Commits

Commit messages should describe why this change is occurring, what problem it is solving, and if the solution isn't immediately obvious, some rationale as to why it was implemented in its current form. 

If you are making multiple independent changes please create separate pull requests per change.

If the changes are a number of distinct steps, a commit per logical progression would be appreciated.

### Bug Fixes

Bug fixes are most welcome and should include a full description of the problem being fixed in the commit message.

### Feature Requests

Before investing too much time in a feature request, please discuss its use on a [GitHub Issues](https://github.com/raasss/docker-mariadb-ubuntu-20.04/issues).

After a feature is written, please help get it used by improving the documentation to detail how to use the newly added feature.

## Improving the Documentation

The [full image description on Docker Hub](https://hub.docker.com/r/raasss/mariadb-ubuntu-20.04) is located at [here](https://github.com/raasss/docker-mariadb-ubuntu-20.04/blob/main/README.docker.io.md).

To change the documentation, please contribute a [pull request](https://github.com/raasss/docker-mariadb-ubuntu-20.04/pulls) or [issue](https://github.com/raasss/docker-mariadb-ubuntu-20.04/issues).


## Current CI Status

| Docker Library Official Images CI Status (released changes) |
|:-:|
| [![latest](https://github.com/raasss/docker-mariadb-ubuntu-20.04/actions/workflows/latest.yml/badge.svg)](https://github.com/raasss/docker-mariadb-ubuntu-20.04/actions/workflows/latest.yml) |
