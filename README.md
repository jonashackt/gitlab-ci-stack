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



# Links

* Gitlab CI REFERENCE docs: https://docs.gitlab.com/ce/ci/yaml/README.html

* Install Gitlab with Docker: https://docs.gitlab.com/omnibus/docker/

* How to build Docker containers with Gitlab: https://docs.gitlab.com/ee/ci/docker/using_docker_build.html

* Why to bind mount docker.sock into your Gitlab Docker Container (instead of using Docker-in-Docker): https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/



