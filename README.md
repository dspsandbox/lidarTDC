# C++ Backend
## Initial configuration 
The following steps target a Linux machine: 

1. Prepare the SD card image. See instructions [here](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842385/How+to+format+SD+card+for+SD+boot). 
2. Download the rootfs:
```
wget -c https://rcn-ee.com/rootfs/eewiki/minfs/ubuntu-18.04.3-minimal-armhf-2020-02-10.tar.xz 
```
3. Extract the rootfs:
```
$ tar xf ubuntu-18.04.3-minimal-armhf-2020-02-10.tar.xz 
```
4. Load the filesystem onto the **root** partition of the SD card and manage permissions:
```
sudo tar xfvp ./*-*-*-armhf-*/armhf-rootfs-*.tar -C /media/<yourUserName>/root/
sync
sudo chown root:root /media/<yourUserName>/root/
sudo chmod 755 /media/<yourUserName>/root/ 
```
5. Download the BOOT.BIN and image.ub binaries from the [repository](https://github.com/dspsandbox/ZynqUbuntu/tree/master/Cora-Z7-10/PetaLinux/images/linux).
6. Upload them onto the **boot** partition:
```
sudo cp  images/linux/BOOT.BIN  /media/<yourUserName>/boot
sudo cp  images/linux/image.ub  /media/<yourUserName>/boot 
```
7. Insert the Sd card into the Cora-z7-10 board and power up the device.

## Static IP address (optional)
Connect over SSH to the Cora-Z7-10 board (user: ubuntu pwd: temppwd) and issue the following commands:
1. Update libraries and install vim:
```
sudo apt update
sudo apt install vim
```
2. Set up a netplan file (.yaml):
```
sudo vim /etc/netplan/01-netcfg.yaml
```
3. Configure the netplan file with your IP address, net mask and gateway:
```
network:
  ethernets:
    eth0:
      dhcp4: no
      dhcp6: no
      addresses: [<IpAddress>/<netMask>, ]
      gateway4:  <gateway>
```
## Install C++ compiler 
```
sudo apt install build-essential
```

## Upload bitstream, source codes...
1. Download this branch
```
git clone --single-branch --branch C++Backend https://github.com/dspsandbox/lidarTDC
```
2. Move into the *remote* folder:
```
cd lidarTDC/remote
```
3. Transfer the folder content to your Zynq. In the following code we use SFTP for it (user: ubuntu pwd: temppwd):
```
sftp <user>@<IpAddress>
```
4. (Optional) Within the SFTP command line create a directory to transfer the files:
```
sftp> mkdir <dirName>
```
5. Within the SFTP command line, move the contents to the remote directory:
```
sftp> cd <dirName>
sftp> mput *
```
6. Quit the SFTP command line:
```
sftp> quit
```

## Build and run test script 
Connect over SSH to the Cora-Z7-10 board (user: ubuntu pwd: temppwd) and issue the following commands.
1. Move to the created remote directory
```
cd <dirName>
```
2. Build test script
```
make
```
3. Run test script
```
./pulseAcqTest
```
![Screen shot](doc/pulseAcqTest.png | width=300)
