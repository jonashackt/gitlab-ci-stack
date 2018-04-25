Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/trusty64"
    config.vm.hostname = "docker-ci-stack"

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
    end

    # Forwarding the Guest to Host ports, so that we can access it easily from outside the VM
    config.vm.network "forwarded_port", guest: 80, host: 30080, host_ip: "127.0.0.1", id: "gitlab"
    config.vm.network "forwarded_port", guest: 443, host: 30443, host_ip: "127.0.0.1", id: "gitlab_https"
    config.vm.network "forwarded_port", guest: 22, host: 30022, host_ip: "127.0.0.1", id: "gitlab_ssh"

end