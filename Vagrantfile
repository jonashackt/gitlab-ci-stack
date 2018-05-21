Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/xenial64"
    config.vm.hostname = "jonashackt"
    # Register domain ci for later access prettiness
    config.dns.tld = "io"

    # As to https://www.vagrantup.com/docs/multi-machine/ & https://www.vagrantup.com/docs/networking/private_network.html
    # we need to configure a private network, so that our machines are able to talk to one another
    config.vm.network "private_network", ip: "172.16.2.15"

    # Forwarding the port for Ansible explicitely to not run into Vagrants 'Port Collisions and Correction'
    # see https://www.vagrantup.com/docs/networking/forwarded_ports.html, which would lead to problems with Ansible later
    config.vm.network "forwarded_port", guest: 22, host: 2222, host_ip: "127.0.0.1", id: "ssh"

    config.vm.provider :virtualbox do |virtualbox|
        virtualbox.name = "docker-ci-stack"
        virtualbox.gui = true
        virtualbox.memory = 4096
        virtualbox.cpus = 2
        virtualbox.customize ["modifyvm", :id, "--ioapic", "on"]
        virtualbox.customize ["modifyvm", :id, "--vram", "32"]
        # Forward DNS resolver from host (vagrant dns) to box
        virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end

    # Forwarding the Guest to Host ports, so that we can access it easily from outside the VM
    config.vm.network "forwarded_port", guest: 80, host: 30080, host_ip: "127.0.0.1", id: "gitlab"
    config.vm.network "forwarded_port", guest: 443, host: 30443, host_ip: "127.0.0.1", id: "gitlab_https"

end