Vagrant.configure("2") do |config|
  config.vm.box = "stakahashi/amazonlinux2"
  config.vm.box_version = "2017.12"

  config.vm.provision "shell", inline: <<-SHELL
    yum update -y

    export PACKER_VERSION=1.1.3
    wget --no-verbose https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -O p.zip && unzip -qq p.zip -d /usr/local/bin && rm -rf p.zip

    packer -v

  SHELL
end
