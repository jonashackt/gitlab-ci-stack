# Prepare Gitlab on a Server (here Vagrant)
# If https_internal_server is set to true, be sure to provide providername, providerusername & providertoken (and maybe whitelist your current Internet IP)
ansible-playbook -i hostsfile prepare-gitlab.yml --extra-vars "providername=yourProviderNameHere providerusername=yourUserNameHere providertoken=yourProviderTokenHere"

# Only, if you don´t use Vagrant or an only internally accessible Server, you can ignore the extra-vars - Gitlab will handle Let´s Encrypt for you then
ansible-playbook -i hostsfile prepare-gitlab.yml

### Provision only certain steps

# Only install Gitlab on the server (skip Docker installation)
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker"

# Create Let´s Encrypt Certificates for our Vagrant Box (non-publicly accessable server)
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker,install_gitlab,gitlab_runner,configure_registry" --extra-vars "providername=yourProviderNameHere providerusername=yourUserNameHere providertoken=yourProviderTokenHere"

# Install Gitlab only
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker,letsencrypt,gitlab_runner,configure_registry"

# Install Container Registry only
ansible-playbook -i hostsfile prepare-gitlab.yml --skip-tags "install_docker,install_gitlab,letsencrypt,gitlab_runner"