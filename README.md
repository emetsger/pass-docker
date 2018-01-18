# Instructions

## Building
The Docker containers _must_ be built prior to starting the demo.  Currently the containers are **not** deployed on the Docker Hub.

1. Check out this repository
2. `cd` into `pass-demo-docker`
  - Peek at `.env` and change any values you wish.  The defaults should work, but if you encounter port conflicts, you may want to change the values of:
      - PY_GGI_PORT
      - FTP_SUBMISSION_DEBUG_PORT
      - FTP_SERVER_PORT
  - The FTP submission code base will be downloaded and built from `SUBMISSION_GIT_REPO`, using the branch or tag defined in `SUBMISSION_GIT_BRANCH` 
  - The Ember code base will be downloaded and built from `EMBER_GIT_REPO`, using the branch or tag defined in `EMBER_GIT_BRANCH`
3. Run `docker-compose build`
  - Lots of things should fly across, including the Maven build of the FTP submission code
  
>If edits are made to any of the `Dockerfile`s or any of their included content (e.g. `cgi_server.py` or content downloaded and built from GitHub), then the containers must be re-built and the demo restarted in order for those edits to take affect.
  
### Starting
1. Run `docker-compose up`

After starting the demo with the defaults, the following services should work.

  - Ember application: [http://localhost:4200](http://localhost:4200)
  - Internal FTP server: `localhost:21`, username: `nihmsftpuser` password: `nihmsftppass`
  - HTTP POST submission trigger: `localhost:8081`
  - Fedora: `localhost:8080/fcrepo/rest`


>(**N.B.** `docker-machine` users will need to substitute the IP address of their Docker machine in place of `localhost`)

### Stopping
1. Type `CTRL-C`
1. Optionally, run `docker-compose down`

## Trigger a Submission with PASS
TODO

## Trigger a Submission Manually
To trigger a submission _without using the PASS Ember UI_:
1. Start the demo
    - `docker-compose up`
2. Send an empty HTTP `POST` request to the submission container, by default port `8081` or whatever `PY_CGI_PORT` is defined as
    - for `docker-machine` users, this will be an IP address like `192.168.99.100`
    - for `Docker for *` users, this will be `localhost`
    - e.g. `curl -X POST localhost:8081`
    - e.g. `curl -X POST 192.168.99.100:8081`

You should see some logs flow across your Docker terminal window, and an indication of a successful FTP upload.

## Configuring Submission FTP site
Submissions may be FTPed to one of two locations:
1. The internal FTP server configured by Docker
2. The NIH test FTP server

By default, the internal FTP server is used.  To use the NIH test FTP server, export an environment variable named `FTP_CONFIGURATION_KEY` with a value of `nih`, then (re)start the demo application using `docker-compose`.  To explicitly configure the internal FTP server, export `FTP_CONFIGURATION_KEY` with a value of `local`.
 
