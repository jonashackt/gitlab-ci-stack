# Prepare Gitlab on a Server (here Vagrant)
ansible-playbook -i hostsfile prepare-gitlab.yml

# Only install Gitlab on the server (skip Docker installation)
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker"


