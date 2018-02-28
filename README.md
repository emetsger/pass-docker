# Instructions

These instructions are for starting the PASS demo instance locally, using Docker.  If you have Docker already installed and want to start up the demo ASAP, jump to [starting Docker](#start).

<h2><a id="prereq" href="#prereq">Prerequisites</a></h2>

1. A working Docker installation: Docker for Mac, Docker for Windows, Docker Linux, or Docker Machine
2. Checkout (i.e. clone) this repository: `git clone https://github.com/OA-PASS/pass-demo-docker`
3. `cd` into `pass-demo-docker`

> Docker Machine users should remember to set the appropriate environment variables in order to select an active machine (e.g. `eval $(docker-machine env default)`), and insure the selected machine is running (e.g. `docker-machine ls`, `docker-machine start default`)

<h2><a id="config" href="#config">Configuring the Docker Images</a></h2>

Configuring the Docker images allows you to:
- change default ports used by the Docker containers
- change the default GitHub repository urls and branches used to build the code included in the images

To configure the Docker images, open up the `.env` file and make any necessary changes.  A brief description of the variables are below:

### Submission package-related variables

  - PY_GGI_PORT: an empty HTTP `POST` to this port triggers the deposit of a dummy submission package to an FTP server 
  - FTP_SUBMISSION_DEBUG_PORT: Used for Java debugging
  - FTP_SERVER_PORT: The FTP command port, typically port 21
  - The FTP submission code base will be downloaded and built from `SUBMISSION_GIT_REPO`, using the branch or tag defined in `SUBMISSION_GIT_BRANCH` 

### Ember application-related variables
  
  - EMBER_PORT: the Ember HTTP application is served on this port
  - The Ember code base will be downloaded and built from `EMBER_GIT_REPO`, using the branch or tag defined in `EMBER_GIT_BRANCH`

### Fedora-related variables
 
  - PASS_FEDORA_PATH: the URL path that the Fedora REST API is served from (e.g. `fcrepo/rest`)
  - Pick one of:
    - PASS_FEDORA_HOST: the base HTTP url of Fedora (e.g. `http://localhost:8080`), and mutually exclusive with `PASS_FEDORA_PORT`.
      - If `PASS_FEDORA_HOST` is present, `PASS_FEDORA_HOST` and `PASS_FEDORA_PATH` are combined to form the publicly accessible Fedora REST API URL.
      - This allows for the Fedora repository to be running on a host distinct from the Ember application 
    - PASS_FEDORA_PORT: the port Fedora is publicly accessible from (**N.B.** this is the variable used by this demo)      
      - If `PASS_FEDORA_PORT` is present, the publicly accessible Fedora REST API URL is formed by the host present in the URL bar of the browser (i.e. the URL used to access the Ember application), the port from `PASS_FEDORA_PORT`, and the path from `PASS_FEDORA_PATH`.
      - This allows for the Fedora repository to be accessible when a host name for Fedora is not known _a priori_ (e.g. when deploying to a cloud service that dynamically supplies IPs or hostnames)
      - A limitation of this approach is that Fedora _must_ be publicly accessible from the same host as the Ember application
  - FCREPO_PORT: the port Fedora runs on (may differ from the port in `PASS_FEDORA_PORT` or `PASS_FEDORA_HOST` when the infrastructure is behind a proxy)
  - FCREPO_JMS_PORT: used by Fedora JMS messaging
  - FCREPO_STOMP_PORT: used by Fedora JMS messaging
  - FCREPO_LOG_LEVEL: sets the log level of the Fedora repository
  - FCREPO_TOMCAT_REQUEST_DUMPER_ENABLED: if set to `true`, instructs Tomcat to dump the headers for each request/response
  - FCREPO_TOMCAT_AUTH_LOGGING_ENABLED: if set to `true`, instructs Tomcat to log additional information regarding authentication and authorization

<h2><a id="build" href="#build">Building the Docker Images</a> (optional)</h2>

If the images deployed to Docker Hub are up-to-date, then you do not need to build the images.

1. Check out this repository
2. `cd` into `pass-demo-docker`
3. Peek at `.env` and change any values you wish; environment variables are documented above
4. Run `docker-compose build`
    - Lots of things should fly across, including the Maven build of the FTP submission code
    - If the build executes quickly, and you see references to cached image layers, then that means that Docker believes the image is already up-to-date (i.e. nothing has changed in the `Dockerfile` for the image).

>Invoke `docker-compose build --no-cache` to insure that content included in the images by `ADD`, `COPY` or GitHub source checkouts is up-to-date
  
<h2><a id="start" anchor="#start">Starting Docker</a></h2>

1. Run `docker-compose up`

If you built the images (or if you already have the images locally from a previous build), services should begin to start right away.  If you did not build the images, Docker will first pull the images from Docker Hub.

After starting the demo with the defaults, the following services should work.

  - Ember application: [https://localhost](https://localhost)
  - Internal FTP server: `localhost:21`, username: `nihmsftpuser` password: `nihmsftppass`
  - HTTP POST submission trigger: `localhost:8081`
  - Fedora: `http://localhost:8080/fcrepo/rest`
  - Same Fedora instance behind a Shibboleth SP: `https://localhost/fcrepo/rest`


>(**N.B.** `docker-machine` users will need to substitute the IP address of their Docker machine in place of `localhost`)

<h2><a id="stop" href="#stop">Stopping</a></h2>

1. Type `CTRL-C`
1. Optionally, run `docker-compose down`

<h2><a id="trigger-pass" href="#trigger-pass">Trigger a Submission with PASS</a></h2>

TODO

<h2><a id="trigger-manual" href="#trigger-manual">Trigger a Submission Manually</a></h2>

To trigger a submission _without using the PASS Ember UI_:
1. Start the demo
    - `docker-compose up`
2. Send an empty HTTP `POST` request to the submission container, by default port `8081` or whatever `PY_CGI_PORT` is defined as
    - for `docker-machine` users, this will be an IP address like `192.168.99.100`
    - for `Docker for *` users, this will be `localhost`
    - e.g. `curl -X POST localhost:8081`
    - e.g. `curl -X POST 192.168.99.100:8081`

You should see some logs flow across your Docker terminal window, and an indication of a successful FTP upload.

<h2><a id="submission-config" href="#submission-config">Configure Submission FTP site</a></h2>

Submissions may be FTPed to one of two locations:
1. The internal FTP server configured by Docker
2. The NIH test FTP server

By default, the internal FTP server is used.  To use the NIH test FTP server, export an environment variable named `FTP_CONFIGURATION_KEY` with a value of `nih`, then (re)start the demo application using `docker-compose`.  To explicitly configure the internal FTP server, export `FTP_CONFIGURATION_KEY` with a value of `local`.

<h2><a id="push" href="#push">Pushing Images to Docker Hub</a></h2>

### Prerequisites for Pushing Images

To push the images to Docker Hub, you must have a Docker Hub account, and have write permissions to the [PASS repository](https://hub.docker.com/u/pass/dashboard/).  

### Image Naming and Tags

Images are identified by: `<repository prefix>/<image name>:<image tag>`, where `<repository prefix>` is the string `pass`: e.g. `pass/ember-fcrepo:0.0.1-demo` 

Image _tags_ are similar to tags in a version control system:  arbitrary strings that resolve a stable set of content.  Tags in Docker can be overwritten, just like tags in a VCS.  

> **Care should be taken when pushing images: overwriting a tag is something that should be done with caution**

Tags are per-image, not per-repository.  That means each image can have its own set of tags (i.e. version semantics).  For example, the [fcrepo](fcrepo/) image may have tags that correspond to the version of [Fedora](http://fedorarepository.org) used by the image:
  - `pass/fcrepo:4.7.1`
  - `pass/fcrepo:4.7.2`
  - `pass/fcrepo:5.0.0`

The [Ember application](ember-fcrepo) may have its own versioning scheme based on feature set:
  - `pass/ember-fcrepo:0.0.1-demo`
  - `pass/ember-fcrepo:0.0.2-demo`
  - `pass/ember-fcrepo:1.0.0`   

### Pushing Images

> **It is imperative to know what tags (i.e. versions) need to be updated, and what the new tags are**

> N.B. it may be completely valid for the tags to remain unchanged, and simply have the images in the Docker Hub be overwritten.  This may be the case especially when updating a development image with the latest code

1. Determine the tag for each image to be pushed
    - Review and update `docker-compose.yml`, if necessary, to use the proper tag(s)
    - Again, it may be the case that tags remain unchanged, in which case the semantics of a push operation are: _Overwrite existing images in Docker Hub_

1. [Build](#build) the images
    - > $ `docker images ls | grep 'pass/'` should return a list of images, including the image names and tags chosen in the previous step
    
1. (Optional) [Start](#start) Docker and test the newly-built images    

1. Push each image individually, specified as `pass/<image name>:<image tag>`
    - > $ `docker push pass/ember-fcrepo:0.0.1-demo`
    - > $ `docker push pass/nihms-submission:1.0.0-SNAPSHOT-demo`
    - > $ # push more images ... 
    
1. If `docker-compose.yml` was updated in step (1), be sure to commit  those changes to Git, and push.
    - > N.B. do _not_ push local changes to `.env`

1. (Optional) Use `git tag` in order to provide traceability for the deployed images
    - > N.B. don't forget to push the tag
