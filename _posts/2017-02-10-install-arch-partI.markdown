---
layout: post
title:  "Installing Arch: Setting up the system"
date:   2017-02-10 08:28:24 -0500
categories: linux arch install
---

I am a fan of [GNU/Linux](https://en.wikipedia.org/wiki/GNU/Linux) (or
just "Linux" if you hate Richard Stallman). My first Linux distro was
[Ubuntu](https://www.ubuntu.com/) but, alas, it was not meant to be.
Though Ubuntu is truly awesome for putting ease of use front and center,
over time my idea of "ease of use" started to drift from Ubuntu's idea
of ease of use.

These days I have gravitated towards Arch. The
[Arch wiki](https://wiki.archlinux.org) is awesome
and a half, and they have a full [installation
guide](https://wiki.archlinux.org/index.php/Beginners%27_guide)
available. However, there is a specific setup I like most and this is
meant to summarize that setup into an easy-to-follow step-by-step guide.

Commands between `[encryption-lvm]` tags need only be run if you want
to set up encryption with LVM and they are run in lieu of commands
in `[standatd]` tags (LVM is recommended; easiest guide I found is
[here](http://www.brandonkester.com/tech/2013/03/16/full-disk-encryption
-in-arch-linux-with-uefi.html)).

Step 1: Partition and format the drive
--------------------------------------

Some basic sanity checks

```bash
ls /sys/firmware/efi/efivars # Should be populated
wifi-menu                    # Will connect automatically
timedatectl set-ntp true
timedatectl status
```

Now partition the disk (EFI)

```bash
# I use parted; alternatively use gdisk or cdisk
parted /dev/sda
mklabel gpt
mkpart ESP fat32 1MiB 513MiB
set 1 boot on

# [encryption-lvm]
mkpart primary ext4 513MiB 100%
# [encryption-lvm]

# [standard]
mkpart primary linux-swap 513MiB 8.5GiB
mkpart primary ext4 8.5GiB 100%
# [standard]

quit
mkfs.vfat /dev/sda1
```

Format drive and mount

```bash
# [encryption-lvm]
cryptsetup luksFormat /dev/sda2
cryptsetup open --type luks /dev/sda2 lvm
pvcreate /dev/mapper/lvm
vgcreate vol0 /dev/mapper/lvm
lvcreate --name lvswap -L 6GB vol0
lvcreate --name lvroot -l 100%FREE vol0
mkswap /dev/mapper/vol0-lvswap
swapon /dev/mapper/vol0-lvswap
mkfs.ext4 /dev/mapper/vol0-lvroot
mount /dev/mapper/vol0-lvroot /mnt
# [encryption-lvm]

# [standard]
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
swapon /dev/sda2
mount /dev/sda3 /mnt
# [standard]

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap -i /mnt base base-devel
# If you get a PGP key error, do
# dirmngr </dev/null
# pacman-key --populate archlinux
# pacman-key --refresh-keys
# Then retun pacstrap
genfstab -U /mnt > /mnt/etc/fstab
cp /etc/netctl/yournetworkname /mnt/etc/netctl/yournetworkname
```

**NOTE:** If you want to mount extra partitions, make sure you mounted them here. For instance, `mkdir  /mnt/mnt/large && mount /dev/sdY1 /mnt/mnt/large` or something, *BEFORE* `genfstab`.

Step 2: Chroot and install base system
--------------------------------------

```bash
arch-chroot /mnt /bin/bash

locale-gen
localectl set-locale LANG=en_US.UTF-8
vi /etc/locale.gen # Uncomment en_US.UTF-8
echo LANG=en_US.UTF-8 > /etc/locale.conf
export `cat /etc/locale.conf`
locale-gen

tzselect
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc --utc

echo vm.swappiness=10 > /etc/sysctl.d/99-sysctl.conf
vi /etc/pacman.conf # Uncomment multilib

echo hostname > /etc/hostname
vi /etc/hosts
# Copy the 127.0.0.1 and replace localhost with hostname

pacman -Sy
pacman -S iw wpa_supplicant dialog intel-ucode
```

Step 3: Configure the boot loader
---------------------------------

_**Pro-tip:**_ I have occasionally messed up my bootloader; when that happens I fire up a live arch USB, mount my partitions (using lvm if applicable), chroot into the system, and fix the bootloader here.

```bash
bootctl install
cp /usr/share/systemd/bootctl/arch.conf /boot/loader/entries/
echo `blkid /dev/sdb2` >> /boot/loader/entries/arch.conf
# File should look like this
#   title   Arch Lnux
#   linux   /vmlinuz-linux
#   initrd  /initramfs-linux.img
# [encryption-lvm]
#   options cryptdevice=UUID=<INSERT-UUID-HERE>:lvm:allow-discards resume=/dev/mapper/vol0-lvswap root=/dev/mapper/vol0-lvroot rw quiet
# [encryption-lvm]
# [standard]
#   options root=PARTUUID=<INSERT-PARTUUID-HERE> rootfstype=ext4 rw
# [standard]

bootctl update
# [encryption-lvm]
# vi /etc/mkinitcpio.conf
#   Add "keymap encrypt lvm2 resume" to HOOKS="..."
#   HOOKS="base udev autodetect modconf block keymap encrypt lvm2 resume filesystems keyboard fsck"
# [encryption-lvm]

mkinitcpio -p linux
passwd
exit
umount -R /mnt/boot
umount -R /mnt
reboot
```

Step 4: Set up your own user account
------------------------------------

```bash
useradd -m -s /bin/bash user
passwd user
visudo # Add to end of file: user ALL=(ALL) ALL
pacman -S sudo bash-completion git rfkill
exit
```

Log in and install install pacaur. You can use `pacaur` (though I think using `yaourt` is more standard) to query the [Arch User Repositories (AUR)](aur.archlinux.org).

```bash
mkdir ~/Documents
mkdir ~/Downloads
mkdir ~/Pictures
mkdir ~/Music
mkdir ~/Videos

cd ~/Downloads
git clone https://aur.archlinux.org/package-query
git clone https://aur.archlinux.org/yaourt
cd package-query
makepkg -si
cd ../yaourt
makepkg -si

# yaourt is supposedly standard but can be very annoying.
# I've been trying out pacaur
gpg --recv-keys 1EB2638FF56C0C53
yaourt -S pacaur
```

You can now follow my preferred setup or go to [the recommendations page](http://https://wiki.archlinux.org/index.php/General_recommendations)
