# Turnkey Riak #

**Mission**

Create a turnkey solution for building, monitoring, and working with a riak cluster on any scale

**Implementation**

In order to make a large scale cluster available to the masses, the solution must leverage a Public Cloud Platform. To start, this project has focused on working with Google's [Cloud Platform](https://cloud.google.com/). However, the project has no hard dependencies on any one cloud provider and support for other platforms will be added over time.

Making the the solution "Turnkey" requires a lot of automation; specifically, cloud orchestration and configuration management. Turnkey Riak uses Hashicorp's [Terraform](http://www.terraform.io) for cloud orchestration. This tool runs locally on a users computer and fully provisions the network and servers in the cloud platform. Terraform will also bootstrap each server such that [Salt](http://saltstack.com) can take over the configuration management of each server instance. Salt further leverages Hashicorp's [consul](http://www,.consul.io) and [consul-template](https://github.com/hashicorp/consul-template) products for service discovery and dynamic configuration files.

Practically speaking, you cannot use a large cluster without the help of some supporting services. Initially, Turnkey Riak provides two of these supporting services, the first being centralized server monitoring provided by [Zabbix](http://www.zabbix.com). Zabbix allows the user to monitor the performance and health of every node in the cluster. The second supporting service is centralized logging provided by Elastic's [ELK Stack](https://www.elastic.co). ELK Stack will centralize the logs from all servers in on location for easy querying.   

## How It Works ##

### Infrastructure ###

![alt text](/assets/images/stack.png "Stack Diagram")

**Network**

A network will be created in your defined GCE project.  Using firewall rules, only a list of trusted IP addresses will be allowed to access the the cluster. A static IP will be created for the load-balancing pool, which will load balance between  HAProxy servers.  

**Server Instances**

* Monitoring Server

    * This server runs the [Zabbix](http://www.zabbix.com/) monitoring system.  It will gather various performance counters and allow you to track and evaluate the performance of the cluster.  Additionally this server is the salt master while also running a salt minion to configure itself.

* Logging Server

    * This server will be deployed with an ELK stack for centralized logging.  All of the other servers will be running beaver to process logs and forward them to the logging server's redis instance.

* Riak Cluster Servers

    * A cluster of Riak servers, using leveldb and solr, will be created and autoconfigured.  The servers will have an SSD disk and a regular disk for the leveldb tiering.  Consul and consul-template are utilized to auto-configure the cluster as nodes come online.

* HAProxy Servers

    * The haproxy servers, using consul and consul-template, will autoconfigure themselves to load balance amongst the riak servers.

### Server Software ###

A variety of software will be installed on the different servers.  Here is a general list with links to each project where you can find documentation.

* [CentOS 7](https://www.centos.org)

    * A Google Compute Engine instance of CentOS 7 will be used as the base image for each server instance in the stack.

* [Salt](http://saltstack.com)

    * Salt is a server configuration management tool, used to install and configure all of the software on the server instances in the stack.  Each server runs a salt-minion daemon which is driven by a salt-master.

* [Consul](https://www.consul.io)

    * Consul is a service discovery tool.  Individual server instances will register their services with the consul cluster, allowing the infrastructure to dynamically discover and utilize services in the stack.

* [consul-template](https://github.com/hashicorp/consul-template)

    * Consul-template utilizes discovered services in consul to automatically build configuration files from templates and reload/restart services as the service infrastructure changes.

* [Riak](http://basho.com/products/riak-kv/)

    * Riak is a highly fault-tolerant distributed key-value store.  This project builds a cluster of riak servers using [leveldb](https://en.wikipedia.org/wiki/LevelDB) for the tiered storage backend and [solr](http://docs.basho.com/riak/latest/dev/using/search/) as a search index.  Consul and consul-template are used to create the cluster on the fly as servers come online and are configured.

* [Zabbix](http://www.zabbix.com)

    * Zabbix is a monitoring system, used to track performance counters and service availability.

* [Elk-stack](https://www.elastic.co)

    * Elastic Co.'s elk stack is used to centralize logging across the servers.  [Beaver](https://pypi.python.org/pypi/Beaver) is used to process and forward logs to the [redis](http://redis.io/) instance used by the elk stack.

* [Banana](https://github.com/LucidWorks/banana/)

    * A fork of Kibana which can be used to visualize data from the solr search/index system used by Riak.  Riak-specific paths are configured using details from [https://github.com/glickbot/riak-banana](https://github.com/glickbot/riak-banana).

* [HAProxy](http://www.haproxy.org/)

    * Haproxy is an open-source load balancing solution.  In this project a pair of haproxy load balancers are built with Google's external load balancing service distributing requests between them.  A real-world production configuration would probably not have external requests being forwarded to the riak servers, and load balancing/fault-tolerance to the haproxy servers would be achieved by using round-robin DNS forwarding to the consul DNS backend.  The haproxy servers are configured using consul-template.

Additional software that will be installed can be found in the salt/states/common and salt/states/profiles directories.

###Execution Flow###

Once the project is executed as detailed below the following actions will occur:

1. Terraform creates a Google Compute Engine (GCE) network, cloud storage bucket, load balancer, and assorted secondary disks for the riak servers.  The salt state files are copied to the bucket.

2. Terraform then creates the Zabbix/Salt Master instance.  A custom startup script is added to the startup script metadata for the server which installs and configures various pre-requisites, such as EPEL, pip, salt, and others, and pulls down the salt configuration files from the storage bucket.  The IP address of this server is captured and fed to the remaining servers via their startup scripts to enable the salt minions on each to contact the master.

3. Terraform then iterates through the module declarations, creating the logging, haproxy and riak servers.  Like the Zabbix server a custom startup script will be applied.

4. Once the servers have booted and executed the startup script the salt minion will contact the salt master.  The salt master has a [reactor](https://docs.saltstack.com/en/latest/topics/reactor/) which auto-adds the minion to the salt master and executes a [highstate](https://docs.saltstack.com/en/latest/topics/tutorials/states_pt1.html) on the minion, which will install and configure all of the software defined in the salt state files.

5. At this point each of the servers should have registered with the consul service.  A variety of additional steps will then be run on each server via consul-template, such as haproxy servers auto-configuring themselves to load balance amongst the riak servers, and the riak servers joining a cluster together.

## Usage ##

#### Prerequisites ####

1. Local Computer

    - This project should run under any Linux distribution without issue. It should also run without issue under OS X.  Theoretically it should also be usable under Windows.

2. Google Cloud Platform Account

    - Sign up for a Google Cloud Platform account [here](https://cloud.google.com)   

3. Google Cloud SDK Installed

    - Follow the instructions at [https://cloud.google.com/sdk/](https://cloud.google.com/sdk/).  Once finished the command-line utilities should be installed.

4. Google Account File Downloaded

    - In order for terraform to access your Google Compute Engine account you will need to provide it credentials.  In the Google Developer's console:

        a. Go to "APIs & auth" and click "Credentials"
        b. Click "Add Credentials" and select "Service Account"
        c. After selecting "Service Account" make sure the radio button in front of JSON is selected, and click "Create"
        d. After a moment it will trigger a download.  Save this file for later

5. Terraform Installed

    - Download and Install Terraform from [https://terraform.io/downloads.html](https://terraform.io/downloads.html)
    - As noted, you need to extract the zip file and place the binaries somewhere on your executable path

6. Turnkey Riak Repository Cloned

    - git clone [https://github.com/physIQ/turnkey-riak.git](https://github.com/physIQ/turnkey-riak.git)


###Configure Turnkey Riak###

1. Add Google Account File to Terraform

    * Simply copy the file from #4 in the prerequisites section to the root directory of the Turnkey Riak project and rename it "account.json"

2. Set Terraform Variables

Terraform uses configuration files written in HCL (hashicorp configuration language).  There are a number of variables to set in the 000-variables.tf file.  The variables marked with "CHANGE REQUIRED" must be changed before you execute Terraform.  Changes to the other variables are optional and will allow you to increase the size and hardware used for the riak cluster.

- **StackName - CHANGE REQUIRED**

	- This variable is used to set the names of various components, such as the Google network name, the server names, etc.  Needs to be unique.

- **ProjectName -CHANGE REQUIRED**

	- The name of the Google project you wish to deploy into.  This must match the project with which you generated the account.json file.

- **trusted_ips - CHANGE REQUIRED**

	- A list of IP addresses which can access your stack.  The firewall created by terraform will only allow these IP addresses.  Since terraform doesn't currently provide a way to declare a list variable this needs to be entered as a comma-delimited text string, in cidr format, without spaces. Example: default = "10.0.0.1/32,10.10.0.0/24"

- **instance_count**

    - The number of haproxy and riak instances to create.  The total number of instances created will be the sum of these numbers plus two - a Zabbix monitoring server and ELK-stack logging server.

- **machine_type**

	- This sets the Google machine type for the instances.  Each are separately configurable.  For a list of Google machine types, see [https://cloud.google.com/compute/docs/machine-types](https://cloud.google.com/compute/docs/machine-types)

- **region_info**

    - All resources will be built in the region and zone defined here.  See [https://cloud.google.com/compute/docs/zones](https://cloud.google.com/compute/docs/zones) for details.

- **ipv4_range**

    - This sets the network address range allocated by terraform.

- **riak_disk_sizes**

    - This sets the size of the leveldb tiered disks attached to the riak servers.  They are divided into "ssd" and "magnetic" - the ssd disks are faster and used for the 1st-tier storage, while the slower magnetic disks are used for the older/slower tiers (see [http://docs.basho.com/riak/latest/ops/advanced/backends/leveldb/](http://docs.basho.com/riak/latest/ops/advanced/backends/leveldb/) for more details).

You should not need to modify any of the other variables or files.

### Terraform Execution ###

1. Download and install necessary terraform modules

    * In the root directory of the Turnkey Riak project execute the following from the command line:

        terraform get

2. Preview Terraforms Execution Plan

   * In the root directory of the Turnkey Riak project execute the following from the command line:

        terraform plan

3. Run Terraform

   * In the root directory of the Turnkey Riak project execute the following from the command line:

        terraform apply

Terraform will now connect to your GCE account and execute as detailed above.  You will see output from terraform detailing the various resources it is creating.  Once terraform has finished you will have to wait for the servers to finish their auto-configuration.  If you wish to monitor these steps, you can log into a server using "gcloud compute ssh server-name" and tail the log file /var/log/startupscript.log.  Once this script has finished executing salt will begin registering with the salt master and executing the highstate.  Once the highstate on a server has finished you should be able to see it by running "consul members"; this will give you a list of all instances that have registered with the consul cluster.

The state of the riak servers can be checked with the command "riak-admin cluster-members" on the first riak server; this command will show you the status of the cluster members and the ring.  Eventually all of the riak servers should be registered with the cluster and have a roughly-equal distribution of data storage.

### Management ###

- Zabbix via http://<monitoring-server-ip>/zabbix ( Admin / zabbix )
- Kibana via http://<logging-server-ip>/logs (no authentication configured)
- Banana via http://<monitoring-server-ip>:4980
- riak cluster via http://<load-balancing-ip>:8093

### Cleanup ###

Once finished you can run the command "terraform destroy" in the root directory of this project.  After you verify by typing "yes" terraform will delete the instances and all associated resources.  Disks may not delete and generate failure messages due to Terraform's timng - if this occurs, simply run "terraform destroy" again.

### Troubleshooting ###

- Can't Access Servers
    - Make sure that the IP addres of the computer you are trying to access the stack from is within a range configured as the trusted IP addresses

## Notes ##
**Known Issues**
 - None at this time.

**Future Improvements**   

 - Support for other Cloud Platform ( AWS, Azure, etc)
 - Add additional cluster support services
