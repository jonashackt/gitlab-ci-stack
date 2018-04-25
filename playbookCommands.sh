# Prepare Gitlab on a Server (here Vagrant)
ansible-playbook -i hostsfile prepare-gitlab.yml

# Only prepare base image springboot-oraclejre-nanoserver
ansible-playbook -i hostsfile prepare-docker-nodes.yml --tags "baseimage"


