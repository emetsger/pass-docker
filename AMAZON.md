These instructions are for deploying the PASS demo to the Amazon Elastic Container Service (ECS).  See [README.md](README.md) for running the PASS demo locally in Docker.  If you have configured the `ecs-cli` already, and want to deploy the containers, jump to [deploying the containers to ECS](#ecs_deploy).

The ECS deployment relies on the existing `docker-compose.yml` in order to provision PASS containers in ECS.  This allows for the application of **DRY** principles: the ECS deployment builds on the [existing Docker deployment](README.md) by adding two "sidecar" files that contain ECS-specific deployment instructions.

Running Docker is _not required_ for deploying to Amazon ECS.  But, Amazon ECS will _pull_ Docker images from Docker Hub during deployment.  So if your use case is "update the ECS deployment with new Docker containers", then you or someone else will need to _push_ the updated containers to Docker Hub _first_, prior to deploying to ECS.  These steps are described [below](#ecs_container_config)

<h1><a id="prereq" href="#prereq">Prerequisites</a></h1>

1. Checkout (i.e. clone) this repository: `git clone https://github.com/DataConservancy/pass-demo-docker`
1. `cd` into `pass-demo-docker`
1. Create an AWS account (e.g. a login to the [Amazon AWS console](http://aws.amazon.com)) if you don't have one
1. [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [quickly configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration) the Amazon AWS CLI
1. [Install](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html) the Amazon ECS CLI (configuration instructions [below](#ecs_cli_config))
1. [Install](https://stedolan.github.io/jq/) JQ
1. Request access to the ECS cluster using instructions below

<h2><a id="ecs_cli_config" href="#ecs_cli_config">Configure your AWS environment</a></h2>

These are one-time configuration instructions.  Once your computer has the ECS CLI installed and configured, you shouldn't need to perform these steps again.

### Create an IAM User

You must create a user using the IAM service, and grant that user permissions to assume the role that manages the cluster.  

1. Navigate to the AWS Console and select the IAM service
2. Choose _Policies_, and create a new policy using the supplied JSON:
```json
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::005956675899:role/ECS_Pass_Cluster_Management"
    }
}
```
3. Name the policy (for example) `assume-role-ECS_Pass_Cluster_Management` and provide a reasonable description.
4. After creating the policy, choose _Groups_, and create a new group named (for example) `pass-cluster-management`.
    - When prompted, attach the policy created earlier, `assume-role-ECS_Pass_Cluster_Management`, to the group.
6. Finally, after creating the group, choose _Users_, and create a new user named (for example) `pass-mgmt`.
    - Check the _Programmatic access_ box (leave others unchecked)
    - When prompted, add the user to the group created earlier, `pass-cluster-management`
9. After creating the user, you will be presented with the AWS access key ID and secret access key.  Place these into your `~/.aws/credentials` file.  The credentials shown below are an example, and use the profile name `default`:
```properties
[default]
aws_access_key_id = AKIA...XXMTYA
aws_secret_access_key = +3/a6...Efq4aA
```

### Requesting access to the ECS Cluster

Contact the administrator of the ECS cluster, and provide them with your IAM user ARN created earlier.  After the administrator has confirmed that you have access, verify that you have access by attempting to assume the role `arn:aws:iam::005956675899:role/ECS_Pass_Cluster_Management`

> $ `aws sts assume-role --role-arn arn:aws:iam::005956675899:role/ECS_Pass_Cluster_Management --role-name pass_mgmt`

If successful, you should be presented with a JSON document that provides a session key, access key id, and a secret access key.

> If you choose an AWS profile name other than `default`, supply the `--profile <profile name>` switch to the above command

### ECS Cluster Configuration

An ECS _cluster_ is: 
> a regional grouping of one or more container instances on which you can run task requests

That is to say, a cluster is where your containers will be deployed.  These instructions assume a _launch_type_ of `FARGATE` and a _region_ of `us-east-1`:
> $ `ecs-cli configure --cluster cluster_name --default-launch-type FARGATE --region us-east-1 --config-name configuration_name`

Normally I use the same value for `cluster_name` and `configuration_name`

After configuring your cluster, you should be able to `cat` the contents of `~/.ecs/config`, and edit it by hand if you wish (e.g. adding more cluster configurations).  An example configuration that defines two clusters (**`pass`** and **`passdev`**) is below:

```yaml
$ cat ~/.ecs/config
 version: v1
 default: passdev
 clusters:
   pass:
     cluster: pass
     region: us-east-1
     default_launch_type: FARGATE
   passdev:
     cluster: passdev
     region: us-east-1
     default_launch_type: FARGATE
```

> *N.B.* You may want **two** cluster definitions to allow for multiple deployments of PASS to run simultaneously.  Theoretically multiple instances of PASS should be deployable in a single cluster, but by default the `ecs-cli` doesn't support it.  Another benefit of using two clusters (and having the default be a _development_ cluster) is that you must explicitly address the production cluster when performing deployment commands (i.e. a default cluster targeting development reduces the risk that you'll blow away a production cluster configuration).

If you have multiple clusters defined, you can set a default cluster by executing:
> $ `ecs-cli configure default --config-name config_name`

Read the [canonical configuration documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_Configuration.html) (optional)

<h1><a id="ecs_container_config" href="#ecs_container_config">Configuring, Building, and Pushing the Docker Containers</a> (optional)</h1>

Whether or not you need to perform these optional steps depends on your use case.  During deployment, Amazon ECS will pull the images to be deployed from Docker Hub.  If the images deployed on Docker Hub _are up-to-date_, then you do _not_ need to perform these optional steps.

If your use case is: _"update the Amazon ECS cloud deployment with the latest code"_, then you or someone else _must_ perform these steps that ultimately end with pushing updated images to Docker Hub.

Because the ECS deployment _extends_ the existing Docker deployment, refer to the following URLs:
- [Docker deployment configuration instructions](README.md#config) for configuring the images and containers.
- [Docker deployment build instructions](README.md#build) for building the images.
- [Docker deployment push instructions](README.md#push) for pushing the images to Docker Hub.

<h1><a id="ecs_deploy" href="#ecs_deploy">Deploying to ECS and Starting Containers</a></h1>

> If you choose an AWS profile name other than `default`, export the `AWS_PROFILE` environment variable equal to your AWS profile name before running ./assume-aws-role.sh

1. Assume the **`ECS_Pass_Cluster_Management`** IAM role if you haven't already:
> $ `eval $(./assume-aws-role.sh)`

This script calls the AWS Secure Token Service to obtain temporary security credentials for the `ECS_Pass_Cluster_Managment` role.  It will set three environment variables:
  - `AWS_SESSION_TOKEN`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_ACCESS_KEY_ID`

Windows users will need to invoke the `amazon sts` command directly, and `set` the same environment variables manually (or donate a PR with a script).


2. Deploying containers to the _default_ cluster using the `ecs-cli` is quite similar to using `docker-compose`:
> $ `ecs-cli compose -f docker-compose.yml -f docker-compose-ecs.yml up`

> If you have defined multiple clusters and the targeted cluster is **not** the default cluster, then add the `-c` command line switch to name the cluster configuration.

Two files are named: the vanilla `docker-compose.yml` used by the local Docker deployment, and another file, in `docker-compose` format, that names additional configuration parameters specific to the ECS deployment.  The output of this command will issue status updates until the containers are successfully deployed.  Note that if the cluster has existing containers that are already running, the `up` command will de-provision and stop those containers before provisioning and starting new ones.

If you want to start multiple instances, you'll need to target a different cluster.

Upon successful deployment, it is natural to want to do two things:
- Determine the IP address of the deployed containers
- View the startup logs

To determine the IP address (and published ports) of the containers, run:
> $ `ecs-cli compose ps`

The output will contain the IP address of the containers, and will include the _task id_ (the UUID included in the "Name" column) and _task name_ (under the "Task Definition" column).

> *N.B.* It may be possible to assign a "static" Elastic IP to the cluster, which would provide for a stable DNS entry.  However, these instructions assume that the containers in the cluster will receive a different IP address each time they are provisioned

To view the logs, run:
> $ `ecs-cli logs --follow --task-id task_id`


<h1><a id="ecs_stop" href="#ecs_stop">Stopping and Removing Containers From ECS</a></h1>

> If you have defined multiple clusters and the targeted cluster is **not** the default cluster, then add the `-c` command line switch to name the cluster configuration.

Stopping and removing containers is as easy as:
> $ `ecs-cli compose down` 

