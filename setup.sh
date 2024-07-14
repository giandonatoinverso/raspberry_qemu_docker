#!/bin/bash
# sudo ./setup.sh "https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2024-07-04/2024-07-04-raspios-bullseye-arm64-lite.img.xz"
set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <IMG file host>"
    exit 1
fi

IMG_FILE="raspberry.img"
IMG_DOWNLOAD=$1

sudo wget -O raspberry.img.xz $IMG_DOWNLOAD
sudo unxz raspberry.img.xz
sudo chmod 600 config/id_rsa
sudo chown $USER:$USER config/id_rsa

PART_INFO=$(fdisk -l $IMG_FILE)
START_SECTOR=$(echo "$PART_INFO" | grep "^$IMG_FILE" | awk '{print $2}' | head -n 1)
OFFSET=$((START_SECTOR * 512))

sudo mount -o loop,offset=$OFFSET $IMG_FILE /mnt
sudo sed -i 's/^/# /' /mnt/etc/ld.so.preload
sudo echo "raspberryPi:$6$rAnjgjG0.K8cPrnU$6Wk1GT0zwFc9CFQrEZi8NMxDtWKzsQN0x/p.x0/tJFYN9FJjphX9n2pXNMFvBDhYxMF1BJUTdS7sRO987dv6S1:1001:0:raspberryPi:/root:/bin/bash" >> /mnt/etc/passwd
sudo echo "raspberryPi	ALL=(ALL:ALL) NOPASSWD: ALL" >> /mnt/etc/sudoers
sudo sed -i 's/defaults,noatime,ro/defaults,noatime,rw/' /mnt/etc/fstab
sudo rm /mnt/etc/ssh/sshd_config
sudo cp config/sshd_config /mnt/etc/ssh/sshd_config
sudo chown root:root /mnt/etc/ssh/sshd_config
sudo chmod 644 /mnt/etc/ssh/sshd_config
touch authorized_keys
cat config/id_rsa.pub >> authorized_keys
sudo mv authorized_keys /mnt/authorized_keys
sudo umount /mnt
sudo docker build -t raspberry_qemu_image .
sudo docker run -d --name qemu_container -p 2225:2225 raspberry_qemu_image

check_ssh_connection() {
    ssh -i config/id_rsa -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no -o ConnectTimeout=60 -q -p 2225 lynis@localhost exit
}

until check_ssh_connection; do
    echo "SSH connection not ready. Sleep time"
    sleep 30
done

echo "SSH connection ready"