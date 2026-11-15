# Disposable VMs for validating the desktop playbook.
#
#   vagrant up ubuntu          # Ubuntu 26.04 "Resolute Raccoon"
#   vagrant up arch            # Arch Linux
#   vagrant provision ubuntu   # re-run the playbook (idempotency check)
#
# The repo is rsynced to ~/dotfiles in the guest so the playbook links configs
# from the same place it would on a real machine. Extra variables can be passed
# as JSON in DOTFILES_EXTRA_VARS.

require "json"

# Needed for the `vm.disk` resize below.
ENV["VAGRANT_EXPERIMENTAL"] ||= "disks"

def provision_with_ansible(vm)
  vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
    ansible.compatibility_mode = "2.0"
    ansible.galaxy_role_file = "requirements.yml"
    ansible.galaxy_command = "ansible-galaxy collection install --requirements-file %{role_file}"
    ansible.extra_vars = { dotfiles_dir: "/home/vagrant/dotfiles" }
      .merge(JSON.parse(ENV.fetch("DOTFILES_EXTRA_VARS", "{}")))
  end
end

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/home/vagrant/dotfiles",
    type: "rsync",
    rsync__exclude: [".git/", ".vagrant/", "niri/.config/niri/config.local.kdl", "fish/.config/fish/fish_variables*"]

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 6144
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga", "--vram", "128", "--accelerate3d", "off"]
  end

  config.vm.define "ubuntu", primary: true do |ubuntu|
    ubuntu.vm.box = "cloud-image/ubuntu-26.04"
    ubuntu.vm.hostname = "dotfiles-ubuntu"
    ubuntu.vm.disk :disk, size: "60GB", primary: true
    provision_with_ansible(ubuntu.vm)
  end

  config.vm.define "arch", autostart: false do |arch|
    arch.vm.box = "archlinux/archlinux"
    arch.vm.hostname = "dotfiles-arch"
    # The box is old and ships without Python, and its rsync is broken until
    # upgraded. A real Arch install already has both (Ansible needs Python).
    arch.vm.provision "bootstrap", type: "shell",
      inline: "pacman -Syu --noconfirm --needed archlinux-keyring python rsync"
    provision_with_ansible(arch.vm)
  end
end
