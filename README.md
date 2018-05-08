docker-ci-stack
======================================================================================
[![Build Status](https://travis-ci.org/jonashackt/docker-ci-stack.svg?branch=master)](https://travis-ci.org/jonashackt/docker-ci-stack)

Full CI pipeline project based on Docker running Gitlab &amp; Gitlab CI, Artifactory, SonarQube fascilitating the Docker Builder Pattern

This project is somehow based on the thought of https://github.com/marcelbirkner/docker-ci-tool-stack. But since the good old days of Jenkins times changed "a bit". Maybe today Jenkins incl. 2.x/Pipeline-plugin isn´t the way to go - or it´s just the way, if you really want to have a hard time. Why? Here are some points:

"Jenkins servers become snowflakes"

"Jenkins 2.0 tries to address this by promoting a Pipeline plugin (plus another plugin to visualize it), but it kind of misses the point."

https://content.pivotal.io/blog/comparing-bosh-ansible-chef-part-1


I heard from so many colleagues: 

> "Hey Jonas you Jenkins fanboy. Have a look on all those cool new CI servers like Concourse, Circle CI oder even Gitlab CI! We don´t know, why you´re messing around with Jenkins..." .

## Which one to choose?

Well, ok then. Let´s give it a try. And because of all this here:

https://www.digitalocean.com/community/tutorials/ci-cd-tools-comparison-jenkins-gitlab-ci-buildbot-drone-and-concourse

https://www.slant.co/versus/2482/10699/~gitlab-ci_vs_concourse-ci

https://www.reddit.com/r/devops/comments/6cuj0s/concourse_jenkins_ci/

https://concourse-ci.org/concourse-vs.html

Therefore I wanted to have a deeper look into Gitlab.

## Gitlab CI

Today Gitlab not only offers a alternative to Bitbucket Server or GitHub Enterprise, they also offer an [alternate CI-Implementation](https://docs.gitlab.com/ce/ci/README.html):

![cicd_pipeline_infograph](cicd_pipeline_infograph.png)

Source: https://docs.gitlab.com/ce/ci/README.html


## Why not just use Docker Compose to fire everything up?

Back in 2015 Marcel already fired up everything with Docker Compose (as I mentioned https://github.com/marcelbirkner/docker-ci-tool-stack). It is also easy to fire up Gitlab with Docker Compose locally, just fire up inside this repo:

`docker-compose up -d`

__BUT__: There are some prerequisites needed for Gitlab CI on your Machine: Docker & Compose have to be installed, and you need to manually install and configure Gitlab Runners - amongst some other things.

What I really love is to achieve comprehensible solutions that are usable as is in your project. And you won´t run your Companie´s Gitlab on your local machine, would you?! You will always try to get a server and install Gitlab there. 

To achieve a fully comprehensible setup here, we some DevOps tools FTW:

* Ansible: This shiny pice will contain __ALL__ steps necessary to provision a Gitlab server with __everything__ needed. It´s also a great documentation what´s needed to setup a Gitlab server.
* Vagrant: To just fire up a server locally that is based on a certain OS - because that´s needed to craft a Ansible playbook. But this is just for demonstration purposes - you can switch over to your Gitlab server by just editing the [hostsfile](hostsfile) and adding `[yourcompanygitlab]` together with it´s IP.

## Let´s install & run Gitlab inside our Server/VagrantBox with Ansible

> All the Installation process is based upon the "Omnibus GitLab installation" (NOT the from source option)

So let´s go: Fire up our server with:

```
vagrant up
```

If the server is up and running (this may take a while when doing it for the first time), we can execute Ansible. 

Let´s do a connection check first. Only at the first run, we also need to surround the `ping` with those environment variables:

```
export ANSIBLE_HOST_KEY_CHECKING=False
ansible docker-ci-stack -i hostsfile -m ping
unset ANSIBLE_HOST_KEY_CHECKING
```

If this gave a `SUCCESS`, we can move on to really execute our ansible script (from the second run on you can start here!).

This will just walk through the standard Gitlab installation guide for Ubuntu - just automatically: https://about.gitlab.com/installation/#ubuntu (others are available also [like CentOS](https://about.gitlab.com/installation/#centos-6):

```
ansible-playbook -i hostsfile prepare-gitlab.yml
```

Now just grab a coffee. If you return to your machine, enter the http://localhost:30080 and your Gitlab should be running fine:

![running-gitlab](running-gitlab.png)


## Install & configure Gitlab Docker Runner

The [gitlab-runner.yml](gitlab-runner.yml) shows how to install and register the Gitlab Docker Runner in non-interactive mode:

As https://docs.gitlab.com/runner/install/linux-repository.html#installing-the-runner states, we need to add the Gitlab Runner package repository and install the Runner via apt-get.

Before we´re able to register the Runner, we need to extract the Registration Token somehow automatically from our Gitlab instance. Since there´s no API at the moment (see https://gitlab.com/gitlab-org/gitlab-ce/issues/24030, https://gitlab.com/gitlab-org/gitlab-runner/issues/1727), we need to obtain it quite hacky through a database call.

The last step then is to register the Gitlab Docker Runner in [non-interactive mode](https://gitlab.com/gitlab-org/gitlab-runner/blob/master/docs/commands/README.md#non-interactive-registration).


## Nice Gitlab URL with DNS configuration

We don´t want to access Gitlab via a http://locahost:30080 call - instead we want to have something like http://docker.gitlab.ci!

To enable that on the Host machine, we need the [vagrant-dns Plugin](https://github.com/BerlinVagrant/vagrant-dns). Just install it with:

```
vagrant plugin install vagrant-dns
```

Now we configure a domain name as `pipeline` in our Vagrantfile:

```
masterlinux.vm.hostname = "pipeline"

masterlinux.dns.tld = "ci"
```

Now we need to register the vagrant-dns Server with the TLD `ci` as a DNS resolver:

```
vagrant dns --install
```

Now check with `scutil --dns` (on a Mac), if the resolver is part of your DNS configuration:

```
...

resolver #10
  domain   : ci
  nameserver[0] : 127.0.0.1
  port     : 5300
  flags    : Request A records, Request AAAA records
  reach    : 0x00030002 (Reachable,Local Address,Directly Reachable Address)

...
```

This looks good! Now after the usual `vagrant up`, try if you´re able to reach our Vagrant Box using our defined domain by typing e.g. `dscacheutil -q host -a name gitlab.pipeline.ci`:

```
$:docker-ci-stack jonashecht$ dscacheutil -q host -a name gitlab.pipeline.ci
  name: gitlab.pipeline.ci
  ip_address: 172.16.2.15
```


But as we want to have the nice `docker.gitlab.ci` also available inside our Vagrant Box and the [vagrant-dns Plugin](https://github.com/BerlinVagrant/vagrant-dns) doesn´t support propagating the host´s DNS resolver to the Vagrant Boxes, we have a problem.
 
But luckily we have [VirtualBox as a virtualization provider for Vagrant](https://www.vagrantup.com/docs/virtualbox/common-issues.html), which supports the propagation of the host´s DNS resolver to the guest machines. All we have to do, is to use [this suggestion on serverfault](https://serverfault.com/a/506206/326340):, which will 'Using the host's resolver as a DNS proxy in NAT mode':

```
# Forward DNS resolver from host (vagrant dns) to box
virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
```

After we configured that, we can do our well-known `vagrant up`.


Now just open up your Browser and go to `docker.gitlab.ci`


## Enable https for Gitlab on public accessable server

https://docs.gitlab.com/omnibus/settings/nginx.html#enable-https

> From 10.7 we will automatically use [Let's Encrypt certificates if the external_url specifies https](https://docs.gitlab.com/omnibus/settings/ssl.html#let-39-s-encrypt-integration)), the certificate files are absent, and the embedded nginx will be used to terminate ssl connections.

If you have an externally accessable server and provision it with these Ansible scripts, you don´t have to worry about the process of obtaining Let´s Encrypt certificates and configuring them for Gitlab. Everything is just done for you by the Gitlab Installation process.


## Let´s Encrypt for our Gitlab on VirtualBox/Vagrant

__BUT__: The problem is our local setup here: Let´s Encrypt wont be able to validate the certificate for our domain, since it´s just a local DNS installation.

That sounds like we´re in need of a different way. Because if we just use our domain with https like https://gitlab.pipeline.ci/, our Browser will complain:

![insecure-https](insecure-https.png)

and a `git push` will result into the following problem:

```
$ git push
fatal: unable to access 'https://gitlab.pipeline.ci/root/yourRepoNameHere/': SSL certificate problem: self signed certificate
```

Although Let´s Encrypt was designed to be used with public accessable websites, there are ways to create these Certificates for non-public servers also. All you need to have is a __regularly registered domain__ - which maybe sounds like a big issue, but isn´t really a problem! (don´t try to use already registered ones, this won´t work!)

If you don´t mind about the tld, choose something like `yourDomainName.yxz` or `yourDomainName.online`, which are available from 1$/year. Just be sure to pick [one from this provider list](https://github.com/AnalogJ/lexicon#providers). 

> There has been done some great work in the field of generating Let´s Encrypt certificates for private servers (see https://blog.thesparktree.com/generating-intranet-and-private-network-ssl)

The playbook [letsencrypt.yml](letsencrypt.yml) (which is choosen if `https_internal_server` is set to `true`) just automates all the steps described in the mentioned post. It uses [dehydrated](https://github.com/lukas2511/dehydrated) as an alternative Let´s Encrypt client togehter with [lexicon](https://github.com/AnalogJ/lexicon), which is standardises the way how to manipulate DNS records via their API [on multiple DNS providers](https://github.com/AnalogJ/lexicon#providers). We install both tools with Ansible:

```
  - name: Update apt
    apt:
      update_cache: yes

  - name: Install openssl
    apt:
      name: openssl
      state: latest

  - name: Install curl
    apt:
      name: curl
      state: latest

  - name: Install sed
    apt:
      name: sed
      state: latest

  - name: Install grep
    apt:
      name: grep
      state: latest

  - name: Install mktemp
    apt:
      name: mktemp
      state: latest

  - name: Install git
    apt:
      name: git
      state: latest

  - name: Install dehydrated
    git:
      repo: 'https://github.com/lukas2511/dehydrated.git'
      dest: /srv/dehydrated

  - name: Make dehydrated executable
    file:
      path: /srv/dehydrated/dehydrated
      mode: "+x"

  - name: Specify our internal domain
    shell: "echo '{{ gitlab_domain }}' > /srv/dehydrated/domains.txt"

  - name: Install build-essential
    apt:
      name: build-essential
      state: latest

  - name: Install python-dev
    apt:
      name: python-dev
      state: latest

  - name: Install libffi-dev
    apt:
      name: libffi-dev
      state: latest

  - name: Install libssl-dev
    apt:
      name: libssl-dev
      state: latest

  - name: Install pip
    apt:
      name: python-pip
      state: latest

  - name: Install requests[security]
    pip:
      name: "requests[security]"

  - name: Install dns-lexicon
    pip:
      name: dns-lexicon
```

As we don´t have a publicly accessable server, we need to use `dns-01` challenges instead of the Let´s Encrypt standard `http-01`. Therefor dehydrated needs a hook file to work with `dns-01`. [lexicon](https://github.com/AnalogJ/lexicon) has such a file for us [/examples/dehydrated.default.sh](https://github.com/AnalogJ/lexicon/blob/master/examples/dehydrated.default.sh) and we copy it simply inside our playbook:

```
  - name: Configure lexicon with Dehydrated hook for dns-01 challenge
    get_url:
      url: https://raw.githubusercontent.com/AnalogJ/lexicon/master/examples/dehydrated.default.sh
      dest: /srv/dehydrated/dehydrated.default.sh
      mode: "+x"
```

At that point we need to use some private information about your DNS provider - because remember, the whole process could __only be done, if you have access to a real domain__. In order to grant lexicon access to your DNS provider´s API, we set some environment variables and then execute dehydrated:

```
  # since, the dynamic with LEXICON_{DNS Provider Name}_{Auth Type}, we need to use shell module with export instead of
  # http://docs.ansible.com/ansible/latest/user_guide/playbooks_environment.html
  - name: Set dehydrated LEXICON_providername_USERNAME
    shell: "export LEXICON_{{providername}}_USERNAME={{providerusername}}"

  - name: Set dehydrated LEXICON_providername_USERNAME
    shell: "export LEXICON_{{providername}}_TOKEN={{providertoken}}"

  # be sure to check https://github.com/AnalogJ/lexicon#providers
  # the env variables are constructed with LEXICON_{DNS Provider Name}_{Auth Type}
  - name: Generate Certificates
    shell: "/srv/dehydrated/dehydrated --cron --hook /srv/dehydrated/dehydrated.default.sh --challenge dns-01"
    environment:
      PROVIDER: providername
```

As you can see, all environment variables are set with the help of Ansible´s `--extra-vars` CLI like this:

```
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker,install_gitlab,gitlab_runner" --extra-vars "providername=yourProviderNameHere providerusername=yourUserNameHere providertoken=yourProviderTokenHere"
```


TODO: 

[configure HTTPS in Gitlab manually](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md#manually-configuring-https).




## Gitlab Container Registry

https://docs.gitlab.com/ee/user/project/container_registry.html

[Gitlab Container Registry domain configuration](https://docs.gitlab.com/ee/administration/container_registry.html#container-registry-domain-configuration)


# Links

* Gitlab CI REFERENCE docs: https://docs.gitlab.com/ce/ci/yaml/README.html

* Install Gitlab with Docker: https://docs.gitlab.com/omnibus/docker/

* How to build Docker containers with Gitlab: https://docs.gitlab.com/ee/ci/docker/using_docker_build.html

* Why to bind mount docker.sock into your Gitlab Docker Container (instead of using Docker-in-Docker): https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/



