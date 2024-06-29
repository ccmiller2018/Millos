#!/bin/bash

# Function to build the kernel
build_kernel() {
    make clean
    make
}

# Function to build Limine if not already present
build_limine() {
    if [ ! -d "limine" ]; then
        git clone https://github.com/limine-bootloader/limine.git --branch=v7.x-binary --depth=1
        make -C limine
    fi
}

# Function to prepare the ISO root directory
prepare_iso_root() {
    mkdir -p iso_root/boot/limine
    cp -v bin/millos iso_root/boot/
    cp -v limine.cfg limine/limine-bios.sys limine/limine-bios-cd.bin \
          limine/limine-uefi-cd.bin iso_root/boot/limine/
    mkdir -p iso_root/EFI/BOOT
    cp -v limine/BOOTX64.EFI iso_root/EFI/BOOT/
    cp -v limine/BOOTIA32.EFI iso_root/EFI/BOOT/
}

# Function to create the bootable ISO
create_iso() {
    xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            --efi-boot boot/limine/limine-uefi-cd.bin \
            -efi-boot-part --efi-boot-image --protective-msdos-label \
            iso_root -o image.iso
}

# Function to install Limine for BIOS boot
install_limine_bios() {
    ./limine/limine bios-install image.iso
}

# Main script execution
build_kernel
build_limine
prepare_iso_root
create_iso
install_limine_bios

echo "Build and ISO creation complete."
