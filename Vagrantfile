Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

   config.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install make
      sudo apt-get install binutils
      sudo apt-get install nasm -y
      sudo apt-get install xorriso -y
      sudo apt-get install git -y
      sudo apt-get install vim -y
      sudo apt-get install -y qemu
      curl -sf https://raw.githubusercontent.com/brson/multirust/master/blastoff.sh | sh -s -- --yes
      multirust default nightly
  SHELL
end
