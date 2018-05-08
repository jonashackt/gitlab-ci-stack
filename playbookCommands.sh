# Prepare Gitlab on a Server (here Vagrant)
ansible-playbook -i hostsfile prepare-gitlab.yml

# Only install Gitlab on the server (skip Docker installation)
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker"

# Create Let´s Encrypt Certificates for our Vagrant Box (non-publicly accessable server)
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker,install_gitlab,gitlab_runner" --extra-vars "providername=yourProviderNameHere providerusername=yourUserNameHere providertoken=yourProviderTokenHere"
