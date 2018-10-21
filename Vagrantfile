# -*- mode: ruby -*-
# # vi: set ft=ruby :
 
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"
 
# Require YAML module
require 'yaml'
 
# Read YAML file with box details
machines = YAML.load_file(File.join(File.dirname(__FILE__), 'machine_define.yaml'))
 
# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

# Don't repalce the Vagrant insecure public key
  config.ssh.insert_key = false
# Update VirtualBox Guest Additions
  config.vbguest.auto_update = true
 
  # Iterate through entries in YAML file
  machines.each do |servers|
    config.vm.define servers["name"] do |srv|
      if srv.vm.box_url == ""
				srv.vm.box = servers["box"]
      else
				srv.vm.box = servers["box"]
				srv.vm.box_url = servers["boxurl"]
      end
			srv.vm.box_check_update = true
      if servers["nettype"] == "private_network"
        srv.vm.network "private_network", ip: servers["ip"], name: servers["subnet"]
      elsif servers["nettype"] == "public"
        srv.vm.network "public"
      elsif servers["nettype"] == "bridged"
        srv.vm.network "private_network", ip: servers["ip"], name: servers["subnet"]
      end
      srv.vm.provider :virtualbox do |vb|
        vb.name = servers["name"]
        vb.memory = servers["ram"]
      end
      srv.vm.provision "ansible" do |a|
        a.playbook = "provision.yml"
        a.verbose = "v"
        a.host_key_checking = false
        a.extra_vars = { ansible_ssh_user: 'vagrant' }
        a.become = true
      end
    end
  end
end
