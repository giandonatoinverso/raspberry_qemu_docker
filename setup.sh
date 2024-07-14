#!/bin/bash
# sudo ./setup_flash.sh
set -x

sudo docker build -t raspberry_qemu_image .
sudo docker run -d --name qemu_container -p 2225:2225 raspberry_qemu_image

check_ssh_connection() {
    ssh -p 2225 pi@localhost exit
}

until check_ssh_connection; do
    echo "SSH connection not ready. Sleep time"
    sleep 30
done

echo "SSH connection ready"