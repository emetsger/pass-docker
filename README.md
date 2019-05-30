# Purpose

This repository serves as the canonical environment for demonstrating integration of the [PASS Ember application](https://github.com/oa-pass/pass-ember) with its dependant services.  This repository provides two things:
1. Docker images that are the basis for the production deployment of PASS, pushed to the [`pass` organization](https://hub.docker.com/u/pass/dashboard/) in Docker Hub 
1. Provides a `docker-compose` orchestration that configures and launches PASS for developers 

# Instructions

These instructions are for starting PASS with `docker-compose`.  If you have Docker already installed and want to start up the demo ASAP, jump to [starting Docker](#start).

<h2><a id="prereq" href="#prereq">Prerequisites</a></h2>

1. Create a "hosts" entry (`C:\Windows\System32\Drivers\etc\hosts` for windows, `/etc/hosts` for *nix) that aliases the hostname `pass.local` to your loopback address (`127.0.0.1`) or to your docker-machine address (e.g. `192.168.99.100`)
2. A working Docker installation: Docker for Mac, Docker for Windows, Docker Linux, or Docker Machine
3. Checkout (i.e. clone) this repository: `git clone https://github.com/OA-PASS/pass-demo-docker`
4. `cd` into `pass-demo-docker`

> Docker Machine users should remember to set the appropriate environment variables in order to select an active machine (e.g. `eval $(docker-machine env default)`), and insure the selected machine is running (e.g. `docker-machine ls`, `docker-machine start default`)

<h2><a id="config" href="#config">Configuring the Docker Images</a></h2>

Configuring the Docker images allows you to:
- change default ports used by the Docker containers
- change the default GitHub repository urls and branches used to build the code included in the images

To configure the Docker images, open up the `.env` file and make any necessary changes.  A brief description of the variables are below:

### NIHMS Submission package-related variables
  - FTP_HOST: NIHMS ftp server
  - FTP_PORT: NIHMS ftp port (default 21)
  - FTP_USER: NIHMS ftp username
  - FTP_PASS: NIHMS FTP pasword

### Ember application-related variables
  
  - EMBER_PORT: the Ember HTTP application is served on this port
  - The Ember code base will be downloaded and built from `EMBER_GIT_REPO`, using the branch or tag defined in `EMBER_GIT_BRANCH`
  - DOI_SERVICE_URL: The relative URL of the DOI service, used at `ember` image _build time_, not run time (default: `/doiservice/journal`)
  - POLICY_SERVICE_URL: The relative URL of the schema service, used at `ember` image _build time_, not run time (default: `/policyservice`)
  - USER_SERVICE_URL: The relative URL of the user service, used at `ember` image _build time_, not run time (default: `/pass-user-service/whoami`)


### Fedora-related variables

  - FCREPO_HOST: The private hostname of Fedora (default `fcrepo`)
  - FCREPO_PORT: the port Fedora runs on (default `8080`)
  - FCREPO_JMS_BASEURL: The URL to use for fedora resources in JMS messages.  This should usually be the private Fedora baseurl (e.g. `http://fcrepo:8080/fcrepo/rest`)
  - FCREPO_JMS_CONFIGURATION: Defines the JMS broker configuration for Fedora.  A value of `classpath:/pass-jms-external.xml` specifies an external activemq.
  - SPRING_ACTIVEMQ_BROKER_URL: ActiveMQ connection URL for connecting Fedora to an external broker (e.g. `failover:(tcp://activemq:61616)?trackMessages=true&maxCacheSize=100000000`)
  - SPRING_ACTIVEMQ_USER: ActiveMQ username for external broker
  - SPRING_ACTIVEMQ_PASSWORD: ActiveMQ password for external broker

#### authz-related env variables relevant to the Fedora image

The Fedora image has two authz-related components installed:  [pass-authz-roles](https://github.com/OA-PASS/pass-authz#pass-authz-roles), and [pass-user-service](https://github.com/OA-PASS/pass-authz#pass-user-service).  Each has their own environment variable configuration:

  - PASS_FEDORA_BASEURL: Private fedora baseURL (e.g. `http://fcrepo:8080/fcrepo/rest`)
  - PASS_ELASTICSEARCH_URL: URL used for elasticsearch queries
  - PASS_FEDORA_USER: User the embedded roles service uses to connect to Fedora (e.g. `fedoraAdmin`)
  - PASS_FEDORA_PASSWORD:  User the embedded roles service uses to connect to Fedora

  - AUTHZ_ALLOW_EXTERNAL_ROLES: (Boolean, default `false`). Normally, the pass-authz-roles is the sole provider of roles. Any pre-existing values in the role header will be erased. Set to true to pass through any roles already defined in the http request (insecure, but helpful for debugging)
  - AUTHZ_HEADER_NAME: (String, default `pass-roles`). HTTP header name to populate with a list of roles. This is the manner by which roles are provided to Fedora
  - AUTHZ_HEADER_SEPARATOR: (String, default `,`). Separator string/character for the list of URIs in the roles http header.
  - AUTHZ_SHIB_USE_HEADERS: (String, default `false`). If true, will look for shibboleth attributes in http headers. By default, it expects shib headers to be provided as request attributes (i.e. environment variables, via the AJP protocol).

  - AUTHZ_SHIB_USE_HEADERS (String, default `false`). If true, will look for shibboleth attributes in http headers. By default, it expects shib headers to be provided as request attributes (i.e. environment variables, via the AJP protocol).
  - AUTHZ_SHIB_CACHE_MINUTES (number, default `10`). This is how long a user's information will be cached before a lookup becomes necessary in Fedora, in minutes.
  - AUTHZ_SHIB_CACHE_SIZE (number, default `100`). Number of users whose information can be cached in memory.
  - PASS_USER_TOKEN_KEY Base32 encoded token key, a secret key shared with the notification link service, and generated by the usertoken key generator application.


#### Esoteric Fedora-related variables (don't use these unless there is reason to)

  - FCREPO_CONNECTIONFACTORY: JMS connection factory (default `=org.apache.activemq.ActiveMQConnectionFactory`)
  - FCREPO_CONTEXT_PATH: Sets the Fedora webapp context path (default `/fcrepo`)
  - FCREPO_DEBUG_PORT: port for the JVM debugger
  - FCREPO_HOME: The Fedora data directory, used for local storage (default `${CATALINA_HOME}/fcrepo4-data`)
  - FCREPO_JMS_PORT: When Fedora is configured to use its internal broker, this sets the activeMQ port
  - FCREPO_JMS_PUBLISHER: determines whether Fedora publishes to a queue or a topic.
  - FCREPO_LOG_LEVEL: sets the log level of the Fedora repository.  Values are TRACE, DEBUG, INFO, WARN
  - FCREPO_LOG_JMS: sets the log level the Fedora messaging component.  Values are TRACE, DEBUG, INFO, WARN
  - FCREPO_LOGBACK_LOCATION: sets the location of a custom configuration file for logging
  - FCREPO_STOMP_PORT: When Fedora is configured to use its internal broker, this sets the STOMP port)
  - FCREPO_TOMCAT_REQUEST_DUMPER_ENABLED: if set to `true`, instructs Tomcat to dump the headers for each request/response
  - FCREPO_TOMCAT_AUTH_LOGGING_ENABLED: if set to `true`, instructs Tomcat to log additional information regarding authentication and authorization

### DSpace-related variables

  - DSPACE_HOST: the host name DSpace will use when generating HTTP responses, defaults to `localhost` (`docker-machine` users _must_ set this to the IP address of their docker-machine)
  - DSPACE_PORT: the port that DSpace and its applications are exposed on, defaults to port `8181`

### Deposit-related variables

- DSPACE_BASEURI: The baseURI (protocol, host, port) of the DSpace instance to deposit into (default: `http://pass.local:8181`)
- DSPACE_USERNAME: SWORD DSpace username
- DSPACE_PASSWORD: SWORD DSpace password
- DSPACE_COLLECTION_HANDLE:  Handle of the collection to deposit into (default: `123456789/2`)

- DEPOSIT_SERVICES_DEBUG_PORT: the port that Deposit Services will listen to for the purposes of attaching a Java debugger (this env var may not work)
- PASS_DEPOSIT_QUEUE_SUBMISSION_NAME: the name of the queue (managed by the ActiveMQ container) that emits messages relating to `Submission` resources
- PASS_DEPOSIT_QUEUE_DEPOSIT_NAME: the name of the queue (managed by the ActiveMQ container) that emits messages relating to `Deposit` resources

A [full](https://github.com/OA-PASS/deposit-services#production-configuration-variables) listing of supported variables for Deposit Services are found [here](https://github.com/OA-PASS/deposit-services#production-configuration-variables).

### Schema service variables
- PASS_EXTERNAL_FEDORA_BASEURL:  External (public) PASS baseurl (e.g. https://pass.local/fcrepo/rest)
- PASS_FEDORA_BASEURL: Internal (private) PASS baseurl (e.g. http://localhost:8080/fcrepo/rest)
- PASS_FEDORA_USER:  Username for basic auth to Fedora (default: "fedoraAdmin")
- PASS_FEDORA_PASSWORD: Password for basic auth to Fedora (default: "moo")
- SCHEMA_SERVICE_PORT: The port the schema service is served on (default: `8086`)

### DOI service variables
The service will look for an environment variable called PASS_DOI_SERVICE_MAILTO to specify a value on the User-Agent header on the Crossref request. If not present, the default is pass@jhu.edu. The service will require the following environment variables for the java client for Fedora if the defaults are not to be used:

- DOI_SERVICE_PORT: The port the DOI service is served on (default: `8090`)
- PASS_FEDORA_USER
- PASS_FEDORA_PASSWORD
- PASS_FEDORA_BASEURL
- PASS_ELASTICSEARCH_URL
- PASS_ELASTICSEARCH_LIMIT

In addition we need PASS_EXTERNAL_FEDORA_BASEURL to be present to translate internal Journal ids to the external form presented to clients

### Policy service variables

- PASS_EXTERNAL_FEDORA_BASEURL:  External (public) PASS baseurl (e.g. https://pass.local/fcrepo/rest)
- PASS_FEDORA_BASEURL: Internal (private) PASS baseurl (e.g. http://localhost:8080/fcrepo/rest)
- PASS_FEDORA_USER:  Username for basic auth to Fedora (default: "fedoraAdmin")
- PASS_FEDORA_PASSWORD: Password for basic auth to Fedora (default: "moo")
- POLICY_SERVICE_PORT: The port the schema service is served on (default: `8088`)
- POLICY_FILE: Location of the policy DSL file.  Baked-in values are `docker.json` (default), and `aws.json` (works in the AWS environment)

### Authz service variables

- PASS_AUTHZ_QUEUE: (String, no `default`). Name of the JMS queue to listen for Fedora messages. For example. Consumer.authz.VirtualTopic.pass.docker
- PASS_BACKEND_ROLE: (URI, no `default`). PASS backend role URI. If unset, will not be used. See authorization roles.
- PASS_GRANTADMIN_ROLE: (URI, no `default`). Grant admin role URI. If unset, will not be used. See authorization roles.
- PASS_SUBMITTER_ROLE: (URI, no `default`). Submitter role URI. If unset, will not be used. See authorization roles.
- JMS_BROKERURL: (URI, default `tcp://localhost:61616`) JMS broker connection URL.
- JMS_USERNAME: (String, no default). JMS connection username. Leave undefined if it is not password protected.
- JMS_PASSWORD: (String, no default). JMS connection password. Leave undefined if it is not password protected.
  
### Postgres-related variables

  - POSTGRES_DB_PORT: the port that the Postgres database is exposed on, defaults to `6543`

### Elasticsearch-related variables

  - ES_PORT: the port that Elasticsearch is exposed on, defaults to `9200`

### PASS indexer related variables

   See [pass-indexer](https://github.com/OA-PASS/pass-indexer) for more info.

  - PI_FEDORA_USER: user to do basic auth with when retrieving Fedora resources
  - PI_FEDORA_PASS: password for basic auth when retrieving Fedora resources
  - PI_FEDORA_INTERNAL_BASE: Internal URI for Fedora. Used to test if it is up.
  - PI_ES_BASE: URL to base of Elasticsearch. Used to test if it is up.
  - PI_ES_INDEX: URL to Elasticsearch index where Fedora resources will be indexed.
  - PI_ES_CONFIG: URL to Elasticsearch index where Fedora resources will be indexed.  
  - PI_FEDORA_JMS_BROKER: location of Fedora JMS broker.
  - PI_FEDORA_JMS_QUEUE: name of Fedora JMS queue
  - PI_TYPE_PREFIX: prefix of Fedora resource type which indicates resource should be indexed
  - PI_LOG_LEVEL: log level of pass-indexer
  - PI_MAX_ATTEMPTS: set the max attempts to contact Elasticsearch and Fedora (default: 20)

### ActiveMQ-related variables

- `ACTIVEMQ_BROKER_URI` URI for clients to connect to the broker, e.g. `failover:tcp://activemq:61616`
- `ACTIVEMQ_JMS_PORT` Openwire wire protocol (ActiveMQ native) port e.g. `61616`
- `ACTIVEMQ_STOMP_PORT`= STOMP wire protocol (text-based) port e.g. `61613`
- `ACTIVEMQ_WEBCONSOLE_PORT`= HTTP port for the ActiveMQ web console (admin/admin) e.g. `8161`

### Mail-related variables

- `MAIL_SMTP`: Mail SMTP port, defaults to `11025`.  This variable really shouldn't be used.
- `MAIL_IMAPS`: IMAP SSL/TLS Port, defaults to `11993`.  This is the port you should configure for an IMAP client to check for messages (_must use SSL or TLS_)
- `MAIL_MSP`: Mail submission port, defaults to `11587`.  This is the port you should use when defining an SMTP mail relay for your application.  _Does not use SSL or TLS, and no authentication is required_
- `OVERRIDE_HOSTNAME`: Set the hostname for the container, defaults to `mail.jhu.edu`.  (This is _not_ the value you use when configuring an email client to talk to the mail container, this is a variable used internally by the mail server itself)
- `ENABLE_SPAMASSASSIN`: `1` enables SA, defaults to `0`.
- `ENABLE_CLAMAV`: `1` enables CLAMAV, defaults to `0`. 
- `ENABLE_FAIL2BAN`: `1` enables fail2ban, defaults to `0`.
- `ENABLE_POSTGREY`: `1` enables postgrey, defaults to `0`.
- `ENABLE_SASLAUTHD`: `1` enables SASL auth, defaults to `0`.
- `SMTP_ONLY`: `1` launches postfix _only_, `0` launches postfix and other daemons.  Defaults to `0`
- `ONE_DIR`: `1` places all configuration files in a single directory (useful for docker volumes).  Defaults to `1`.
- `DMS_DEBUG`: Debug the `docker/mailserver`.  `1` enables debugging, defaults to `0`.
- `ENABLE_LDAP`: Enables LDAP for postfix and dovecot, defaults to `1`.  Allows for the users LDIF maintained in the LDAP container to be used for email address resolution and delivery.
- `TLS_LEVEL`: Allowed TLS ciphers, defaults to `intermediate` so that most modern IMAP clients can connect
- `LDAP_SERVER_HOST`: the LDAP server hostname, defaults to `ldap`
- `LDAP_SEARCH_BASE`: the base DN for executing LDAP searches for people, defaults to `ou=People,dc=pass`
- `LDAP_BIND_DN`: the administrator DN, used to perform LDAP searches when binding as the user isn't an option, defaults to `cn=admin,dc=pass`
- `LDAP_BIND_PW`: the adminstrator bind DN password
- `LDAP_QUERY_FILTER_USER`: LDAP search filter for resolving potential email recipients, defaults to `(&(objectClass=posixAccount)(mail=%s))`
- `LDAP_QUERY_FILTER_GROUP`: LDAP search filter for resolving potential mail groups, defaults to `(&(objectClass=posixAccount)(mailGroupMember=%s))`
- `LDAP_QUERY_FILTER_ALIAS`: LDAP search filter for resolving potential mail aliases, defaults to `(&(objectClass=posixAccount)(mailAlias=%s))`
- `LDAP_QUERY_FILTER_DOMAIN`: LDAP search filter for resolving domains the mail server answers to, defaults to `(|(mail=*@%s)(mailalias=*@%s)(mailGroupMember=*@%s))`
- `POSTMASTER_ADDRESS`: The postmaster email address, defaults to `root`

### Notification Services Environment

The environment variables for Notification Services are a function of what is present in the [application.properties](https://github.com/OA-PASS/notification-services/blob/master/notification-boot/src/main/resources/application.properties), and what is present in the [notification.json configuration file](notification-services/0.0.1-3.2) for `pass-docker`.

Defaults provided by the `pass-docker` environment override defaults provided in the `application.properties`.

#### Spring-Boot application.properties Environment

Supported environment variables (system property analogs) and default values are:

- `SPRING_ACTIVEMQ_BROKER_URL` (`spring.activemq.broker-url`): URL used to connect to ActiveMQ for receiving JMS messages (`${activemq.broker.uri:tcp://${jms.host:localhost}:${jms.port:61616}}`)
- `SPRING_JMS_LISTENER_CONCURRENCY` (`spring.jms.listener.concurrency`): number of JMS listeners to start- one thread per listener (`4`)
- `SPRING_JMS_LISTENER_AUTO_STARTUP` (`spring.jms.listener.auto-startup`): whether JMS listeners should be started on boot (`true`)
- `PASS_NOTIFICATION_QUEUE_EVENT_NAME` (`pass.notification.queue.event.name`): the JMS queue listened to by NS (`event`)
- `PASS_FEDORA_USER` (`pass.fedora.user`): user used to connect to the Fedora repository REST API (`fedoraAdmin`)
- `PASS_FEDORA_PASSWORD` (`pass.fedora.password`): password used to connect to the Fedora repository REST API (`moo`)
- `PASS_FEDORA_BASEURL` (`pass.fedora.baseurl`): base URL of the Fedora repository REST API (`http://${fcrepo.host:localhost}:${fcrepo.port:8080}/fcrepo/rest/`)
- `PASS_ELASTICSEARCH_URL` (`pass.elasticsearch.url`): base URL of the ElasticSearch API for the PASS index (`http://${es.host:localhost}:${es.port:9200}/pass`)
- `PASS_ELASTICSEARCH_LIMIT` (`pass.elasticsearch.limit`): number of records retrieved by default when performing a search of the index (`100`)
- `PASS_NOTIFICATION_MODE` (`pass.notification.mode`): runtime mode of Notification Services, one of `DISABLED`, `DEMO`, `PRODUCTION` (`DEMO`)
- `PASS_NOTIFICATION_SMTP_HOST` (`pass.notification.smtp.host`): SMTP server used by NS to send email (`${pass.notification.smtp.host:localhost}`)
- `PASS_NOTIFICATION_SMTP_PORT` (`pass.notification.smtp.port`): SMTP port used by NS to send email (`${pass.notification.smtp.port:587}`)
- `PASS_NOTIFICATION_SMTP_USER` (`pass.notification.smtp.user`): user used to connect to the SMTP relay (`<empty string>`)
- `PASS_NOTIFICATION_SMTP_PASS` (`pass.notification.smtp.pass`): password used to connect to the SMTP relay (`<empty string>`)
- `PASS_NOTIFICATION_SMTP_TRANSPORT` (`pass.notification.smtp.transport`): transport used to communicate with the SMTP relay, one of `SMTP`, `SMTPS`, `SMTP_TLS` (`${pass.notification.smtp.transport:SMTP}`)  
- `PASS_NOTIFICATION_MAILER_DEBUG` (`pass.notification.mailer.debug`): enable debugging for the Java Mail API (`false`)
- `PASS_NOTIFICATION_CONFIGURATION` (`pass.notification.configuration`): location of the Notification Service runtime configuration file (`classpath:/notification.json`)
- `PASS_NOTIFICATION_HTTP_AGENT` (`pass.notification.http.agent`): user agent string used by the PASS Java Client when communicating with the Fedora repository or ES (`pass-notification/x.y.z`)

#### pass-docker Environment

- `NOTIFICATION_DEBUG_PORT`: port for attaching a remote debugger to the JVM (`5011`)
- `PASS_NOTIFICATION_QUEUE_EVENT_NAME`: the JMS queue listened to by NS (`Consumer.event.VirtualTopic.pass.docker`)
- `PASS_NOTIFICATION_MODE`: runtime mode of Notification Services, one of `DISABLED`, `DEMO`, `PRODUCTION` (`DEMO`)
- `PASS_NOTIFICATION_CONFIGURATION`: location of the Notification Service runtime configuration file (`file:/notification.json`)
- `PASS_NOTIFICATION_SMTP_HOST`: SMTP server used by NS to send email (`mail`)
- `PASS_NOTIFICATION_SMTP_PORT`: SMTP port used by NS to send email (`587`)
- `PASS_NOTIFICATION_SMTP_USER`: user used to connect to the SMTP relay (`<empty string>`)
- `PASS_NOTIFICATION_SMTP_PASS`: password used to connect to the SMTP relay (`<empty string>`)
- `PASS_NOTIFICATION_SMTP_TRANSPORT`:  transport used to communicate with the SMTP relay, one of `SMTP`, `SMTPS`, `SMTP_TLS` (`SMTP`)

- `PASS_NOTIFICATION_TEMPLATE_APPROVAL_INVITE_SUBJECT`: Spring Resource URI for `SUBMISSION_APPROVAL_INVITE` email subject (`file:/templates/approval-invite-subject.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_APPROVAL_INVITE_BODY`: Spring Resource URI for `SUBMISSION_APPROVAL_INVITE` email body (`file:/templates/approval-invite-body.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_APPROVAL_INVITE_FOOTER`: Spring Resource URI for `SUBMISSION_APPROVAL_INVITE` email footer (`file:/templates/footer.hbr`)

- `PASS_NOTIFICATION_TEMPLATE_APPROVAL_REQUESTED_SUBJECT`: Spring Resource URI for `SUBMISSION_APPROVAL_REQUESTED` email subject (`file:/templates/approval-requested-subject.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_APPROVAL_REQUESTED_BODY`: Spring Resource URI for `SUBMISSION_APPROVAL_REQUESTED` email body (`file:/templates/pproval-requested-body.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_APPROVAL_REQUESTED_FOOTER`: Spring Resource URI for `SUBMISSION_APPROVAL_REQUESTED` email footer (`file:/templates/footer.hbr`)

- `PASS_NOTIFICATION_TEMPLATE_CHANGES_REQUESTED_SUBJECT`: Spring Resource URI for `SUBMISSION_CHANGES_REQUESTED` email subject (`file:/templates/changes-requested-subject.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_CHANGES_REQUESTED_BODY`: Spring Resource URI for `SUBMISSION_CHANGES_REQUESTED` email body (`file:/templates/changes-requested-body.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_CHANGES_REQUESTED_FOOTER`: Spring Resource URI for `SUBMISSION_CHANGES_REQUESTED` email footer (`file:/templates/footer.hbr`)

- `PASS_NOTIFICATION_TEMPLATE_SUBMISSION_SUBMITTED_SUBJECT`: Spring Resource URI for `SUBMISSION_SUBMISSION_SUBMITTED` email subject (`file:/templates/submission-submitted-subject.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_SUBMISSION_SUBMITTED_BODY`: Spring Resource URI for `SUBMISSION_SUBMISSION_SUBMITTED` email body (`file:/templates/submission-submitted-body.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_SUBMISSION_SUBMITTED_FOOTER`: Spring Resource URI for `SUBMISSION_SUBMISSION_SUBMITTED` email footer (`file:/templates/footer.hbr`)

- `PASS_NOTIFICATION_TEMPLATE_SUBMISSION_CANCELLED_SUBJECT`: Spring Resource URI for `SUBMISSION_SUBMISSION_CANCELLED` email subject (`file:/templates/submission-cancelled-subject.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_SUBMISSION_CANCELLED_BODY`: Spring Resource URI for `SUBMISSION_SUBMISSION_CANCELLED` email body (`file:/templates/submission-cancelled-body.hbr`)
- `PASS_NOTIFICATION_TEMPLATE_SUBMISSION_CANCELLED_FOOTER`: Spring Resource URI for `SUBMISSION_SUBMISSION_CANCELLED` email footer (`file:/templates/footer.hbr`)

- `PASS_NOTIFICATION_DEMO_FROM_ADDRESS`: From email address for all notifications send in `DEMO` mode (`noreply@pass.jh.edu`)
- `PASS_NOTIFICATION_DEMO_GLOBAL_CC_ADDRESS`: Global carbon copy email address for all notifications sent in `DEMO` mode (`notification-demo-cc@jhu.edu`)

- `PASS_NOTIFICATION_PRODUCTION_FROM_ADDRESS`: From email address for all notifications send in `PRODUCTION` mode (`noreply@pass.jh.edu`)
- `PASS_NOTIFICATION_PRODUCTION_GLOBAL_CC_ADDRESS`:  Global carbon copy email address for all notifications sent in `PRODUCTION` mode `(<empty string>)`


### Setting up a mail client

In order to view notifications sent by Notification Services (NS), you must configure an IMAP client to communicate with the mail server run in `pass-docker`.

Briefly, you should use the following settings:
- IMAP server: the IP address of the docker host (e.g. `192.168.99.100` for docker-machine users, or `localhost` for others)
- IMAP port: `11993`
- You _must_ use secure IMAP (SSL).  Some clients combine SSL with TLS (e.g. "SSL/TLS"), others make it an explicit choice.  If you have a choice, use SSL.  Otherwise chose the option that includes SSL.

Each email address listed in LDAP is allowed to login and receive email.  The username for IMAP login is the same as the user's email address.  For example, if you wanted to log in and check the email for `staff1`, the IMAP user name would be `staffWithGrants@jhu.edu`.  The IMAP username for `faculty2` would be `facultyWithNoGrants@jhu.edu`.  You can configure an account for every IMAP user if you wish, but if you know you'll only be testing with two or three LDAP users, then you only need to configure IMAP accounts for the users you are testing with.

If you wish, you can configure an outgoing SMTP server, but that is not necessary for testing NS
- Outgoing SMTP server: the IP address of the docker host (e.g. `192.168.99.100` for docker-machine users, or `localhost` for others)
- Outgoing SMTP port: `11587`
- Do *not* use SSL or TLS
- No username or password is required (do not use SMTP auth)

**Note:** Sometimes there is trouble when initially connecting to the mail server using IMAP SSL.  You must be able to accept a fake certificate in your mail reader before continuing to communicate with the IMAP server.  This is sometimes problematic.  For example, in Mac Mail, it takes a long time (2-3 minutes?) for Mac Mail to prompt for the acceptance of the SSL certificate.  This behavior may be related to issue [45](https://github.com/OA-PASS/notification-services/issues/45).  The hostname presented by the SSL certificate is not an RFC-valid DNS hostname, and may cause some trouble.  

The Mac Mail "Connection Doctor", combined with the log output from the `pass-docker` `mail` container (`docker logs mail`) can help troubleshoot the underlying problem.

When initially setting up accounts in Mac Mail, be sure to double-check the IMAP connection parameters (hostname, port, SSL) before digging deeper.  The initial account setup dialog for Mac Mail is not intuitive, and takes a bit of persistence to get set up with the correct parameters.

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

The PASS home page is accessible at `https://pass.local`.  It links to the pass ember app at `https://pass.local/app`.  These are the correct URLs to use
You'll be prompted to log in as necessary.  Use one of the [Shibboleth users](#shibboleth-users) below to log in.


After starting the demo with the defaults, the following services shoud be accessible directly to developers:

  - Ember application: [https://pass.local/app](https://pass.local/app). _See [Shibboleth users](#shibboleth-users) below for login options_ 
  - Internal FTP server: `localhost:21`, username: `nihmsftpuser` password: `nihmsftppass`
  - HTTP POST submission trigger: `localhost:8081`
  - Fedora: `http://localhost:8080/fcrepo/rest`
  - Same Fedora instance behind a Shibboleth SP: `https://pass.local/fcrepo/rest`
  - DSpace repository, exposed at port `8181`: `http://localhost:8181/xmlui`
      - Login with username `dspace-admin@oapass.org`, password `foobar`
      - Not behind the Shibboleth SP
  - DSpace SWORD v2 endpoint: `http://localhost:8181/swordv2/servicedocument`
      - Protected by HTTP basic auth
      - Authenticate with username `dspace-admin@oapass.org`, password `foobar`
      - Not behind the Shibboleth SP
  - Postgres database, exposed at port `6543`
      - DSpace database name `dspace`, username `dspace`, no password
	  
>(**N.B.** `docker-machine` users will need to substitute the IP address of their Docker machine in place of `localhost`)

### Shibboleth users
There are four users that can log in via Shibboleth. These can be used to log in to Ember. Each uses the password `moo`.
* `staff1` A staff member who does have grants and therefore does have a User resource already, and is the PI on grants.
* `staff2` A staff member who does not have grants. Because PASS policy is to only allow faculty in, this user will be denied access to the user service, or the repository.
* `faculty1` A faculty member who does have lots of grants, and therefore does have a User resource already, and is a PI on grants.
* `faculty2` A faculty member who does not have grants. Because PASS policy is to give faculty submitter privileges, the first time this person logs to shibboleth and hits the user service, a new User resource is created, but the user should not be allowed to associate grants with his or her submissions.
* `nih-user` Person with NIH grants
* `ed-user` Person with DOE gtants
* `usaid-user` Person with USAID grants
* `incomplete-nih-user` Person with incomplete submissions harvested from NIHMS
* `admin` Grant admin
* `admin-submitter` A superuser-like user who can see all submissions/grants, and also create their own
* `superuser` DOES NOT WORK, needs an update to the user roles enum in the java client.  An experimental superuser who has admin and submitter provileges, but also has permission to write to any resource.


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
