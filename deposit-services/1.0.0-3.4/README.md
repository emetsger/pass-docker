# Deposit Services Docker Images

Deposit Services is composed of a hierarchy of images:

* `oapass/deposit-pass-docker` (maintained [here](./Dockerfile), in `pass-docker`) depends on:
    * `oapass/deposit-services-providers` (maintained [here][0] in [jhu-package-providers][1]) depends on:
        * `oapass/deposit-services-core` (maintained [here][2] in [deposit-services][3])

Cutting a release of `oapass/deposit-services-core` will require a release of `oapass/deposit-services-providers` followed by a release of `oapass/deposit-pass-docker`.

Notably `oapass/deposit-pass-docker` maintains the Deposit Services runtime configuration, [`repositories.json`][6].

## Update Process
        
If an image needs to be modified, then you will need to update that image, and any dependant images.

1. Check out the GitHub repository that maintains the `Dockerfile` for the image,
1. Make your adjustments to the `Dockerfile`, 
1. And run `mvn install` in the base directory of the repository.  This will build the image, which you can verify by running `docker images`.
1. Then, build any images that depend on the image you just built.

For example, if you need to adjust the [`aws_entrypoint.sh`][4] in [deposit-services][3]:
1. Check out [deposit-services][3]
2. Edit `deposit-messaging/src/main/docker/bin/aws_entrypoint.sh`
3. Run `mvn install`, verify the image was built using `docker images`
4. Build the dependent image `oapass/deposit-services-providers` by checking out [jhu-package-providers][1] and running `mvn install` (verifying image was build with `docker images`)
5. Run `docker-compose build deposit` in this project

This process will update your _local_ images, _i.e._ changes you have made will be available in the images on your computer, but won't be visible to others.  For your changes to be seen by others will require that the images be pushed to Docker Hub.  Typically this is accomplished by opening a PR with your changes and merging the PR.

## PRs and Travis image deployment

[deposit-services][3] and [jhu-package-providers][1] are configured to build and push their Docker images to Docker Hub each time a PR is successfully merged to `master`.  The Docker Maven Plugin is invoked during the Maven `deploy` phase to push the images.

Furthermore, the Travis build for `deposit-services` is [designed][7] to [trigger][8] a build of [jhu-package-providers][1] each time `deposit-services` successfully builds.  This insures that each time a PR to `deposit-services` is merged to `master`, not only is `oapass/deposit-services-core` pushed to Docker Hub, but `jhu-package-providers` is also built, and `oapass/deposit-services-providers` is pushed to Docker Hub.  That way the `oapass/deposit-services-providers` image is always properly derived from the most recent `oapass/deposit-services-core` image.

There is no automated trigger of `oapass/pass-docker` by `oapass/jhu-package-providers`.  Pushing the `oapass/deposit-pass-docker` from `pass-docker` is done manually, just like any other image maintained in `pass-docker`.

## Releasing images

When cutting releases for images, relying on the automated builds by Travis alone are not sufficient.  Dependant projects need to update the version of the upstream image being depended on.  

Typically the image maintained by any project will be tagged as a SNAPSHOT, _e.g._ `oapass/deposit-services-providers:0.0.1-SNAPSHOT` or `oapass/deposit-services-core:1.0.0-3.4-SNAPSHOT` (the Docker image tag is the same as the version of the project in the Maven POM).  When releasing a image, `-SNAPSHOT` should be removed from the image tag.  Importantly, any downstream projects that depend on the image will need to be updated to use the newly released image tag, sans `-SNAPSHOT`.  Using the `maven-release-plugin` to perform releases will reduce the chance for errors in the release process, and insure that downstream projects are updated correctly.

For example, the current version of `deposit-services-core` is `1.0.0-3.4-SNAPSHOT`.  The current version of `jhu-package-providers` is `0.0.1-SNAPSHOT`, and depends on `deposit-services-core:1.0.0-3.4-SNAPSHOT`.  The `maven-release-plugin` will be used to release `deposit-services-core:1.0.0-3.4` (no `-SNAPSHOT`).  The Travis build of `deposit-services-core` will create and push the `oapass/deposit-services-core:1.0.0-3.4` to Docker Hub.  

Next, `jhu-package-providers` is released with the `maven-release-plugin`, and during that process the dependency on `deposit-services-core:1.0.0-3.4-SNAPSHOT` is resolved to `deposit-services-core:1.0.0-3.4`.  The Travis build of `jhu-package-providers` will create and push the `oapass/deposit-services-providers:0.0.1` image, which properly depends on `deposit-services-core:1.0.0-3.4`.

## Maintenance Locations

* `oapass/deposit-pass-docker`
    * Maintained in [`pass-docker`][5]
    * [`Dockerfile`](./Dockerfile)
    * Docker Hub: https://cloud.docker.com/u/oapass/repository/docker/oapass/deposit-pass-docker
    * Deposit Services runtime configuration: [`repositories.json`][6]
* `oapass/deposit-services-providers`
    * Maintained in [jhu-package-providers][1]
    * [`Dockerfile`][0]
    * Docker Hub: https://cloud.docker.com/u/oapass/repository/docker/oapass/deposit-services-providers
* `oapass/deposit-services-core`
    * Maintained in [deposit-services][3]
    * [`Dockerfile`][2]
    * Docker Hub: https://cloud.docker.com/u/oapass/repository/docker/oapass/deposit-services-core
    
    


[0]: https://github.com/OA-PASS/jhu-package-providers/blob/master/provider-integration/src/main/docker/Dockerfile
[1]: https://github.com/OA-PASS/jhu-package-providers/
[2]: https://github.com/OA-PASS/deposit-services/blob/master/deposit-messaging/Dockerfile
[3]: https://github.com/OA-PASS/deposit-services/
[4]: https://github.com/OA-PASS/deposit-services/blob/master/deposit-messaging/src/main/docker/bin/aws_entrypoint.sh
[5]: https://github.com/OA-PASS/pass-docker/
[6]: ./repositories.json
[7]: https://github.com/OA-PASS/deposit-services/blob/master/.travis.yml#L30
[8]: https://github.com/OA-PASS/deposit-services/blob/master/trigger-dependent-build