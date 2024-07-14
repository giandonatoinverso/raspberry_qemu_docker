# Raspberry QEMU Docker

This repository allows you to virtualize the Raspbian operating system through QEMU+Docker.
- The project is based on the article https://interrupt.memfault.com/blog/emulating-raspberry-pi-in-qemu
- The setup.sh file takes as its only parameter a URL from which to download the image to be virtualized

Example:
```bash
sudo ./setup.sh "https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2024-07-04/2024-07-04-raspios-bullseye-arm64-lite.img.xz"
```

## Pre-processing

Before starting virtualization it is necessary to carry out some operations:

- **Download and prepare a Raspberry Pi OS image**
  - Downloads the specified Raspberry Pi OS image file.
  - Uncompresses the downloaded image.
- **Modify the image**
  - Sets up SSH keys and configures SSH access.
  - Disables a preload library for compatibility.
  - Creates a user with sudo privileges.
  - Adjusts filesystem settings for read/write access.
  - Replaces the SSH configuration with a custom one.
- **Build and run a Docker container**
  - Builds a Docker image with QEMU to emulate the Raspberry Pi environment.
  - Runs the Docker container and forwards a port for SSH access.
- **Check SSH connectivity**
  - Continuously attempts to establish an SSH connection to the running container until successful.

## Docker virtualization

- **Set up the base image**:
  - Uses Ubuntu 20.04 as the base image.

- **Install necessary packages**:
  - Installs `qemu-system-aarch64`, `fdisk`, `wget`, `mtools`, and `xz-utils`.

- **Prepare the working environment**:
  - Sets the working directory to `/qemu`.
  - Copies the `raspberry.img` file into the working directory.
  - Sets an environment variable for the image file.

- **Resize the image file**:
  - Resizes the Raspberry Pi image file to the next power of two in size.

- **Extract necessary files from the image**:
  - Finds the offset of the FAT32 partition in the image.
  - Configures `mtools` to access the FAT32 partition.
  - Copies the kernel and device tree files from the image.

- **Set up SSH access**:
  - Creates necessary files to enable SSH and set a default password.

- **Copy SSH configuration files into the image**:
  - Copies the SSH enabling file and the user configuration file into the image.

- **Expose SSH port**:
  - Exposes port 2225 for SSH access.

- **Run QEMU**:
  - Starts QEMU to emulate a Raspberry Pi 3B+ with specified parameters and port forwarding for SSH.