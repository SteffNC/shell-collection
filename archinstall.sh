#!/bin/bash

### Arch Installer with UEFI and encrypted LVM, created by SteffNC
## Last updated 20.10.23

clear

echo "Guide for an automatic encrypted installation of Arch Linux with UEFI and LVM - 20.10.21 (c) SteffNC"
echo ""

SIZEHDD=$(blockdev --getsize64 /dev/sda | awk '{ print $1/1024/1024/1024}')
echo "Disk with $SIZEHDD GB (/dev/sda) used"
echo ""
sleep 1
echo ""
echo ""
lsblk
echo ""
echo "1. Preparation of disk and encryption"
echo "2. Preparation of chrooted installation"
echo "3. Finalization of installation"
echo ""
echo "4. Decrypt and mounting the device /dev/sda"
echo "5. Generate EFI entries UUID or by device"

echo ""

echo "6. Install on NVM drive, issue command: sed 's/sda/nvme0n1p/g' archinstall.sh"
echo "7. Install on any connected drive"

echo ""
echo "8. Increase font size: setfont /usr/share/kbd/consolefonts/ter-k32b.psf.gz"
echo "9. Erase encrypted drive"
echo ""
echo "Connect WLAN: iwctl --passphrase passphrase station device connect SSID"
echo "Uge font: setfont /usr/share/kbd/consolefonts/solar24x32.psfu.gz"





function generateEFIentries {

        read -r -p "What CPU do you use? (a)md, (i)ntel, (h)yper-V, or (v)virtual? " cpu


        if [[ "$cpu" = "a" ]]
            then
                line="initrd /amd-ucode.img"
                options=""

                pacman -S amd-ucode
                pacman -S mesa

                echo "Remember to add mkinitcpio modules: amdgpu radeon !"

                sleep 3

        elif [[ "$cpu" = "i" ]]
            then
                line="initrd /intel-ucode.img"
                options=""

                pacman -S intel-ucode

                echo "Remember to add mkinitcpio modules: i915 !"
                sleep 3

        elif [[ "$cpu" = "v" ]]
            then
                line=""
                options=""

                pacman -S virtualbox-guest-utils xf86-video-vmware

        elif [[ "$cpu" = "h" ]]
            then
                line=""
                options="video=hyperv_fb:1920x1080"
        fi



        read -r -p "Please choose cryptdevice: [u]uid or /[d]ev/sda2 " cdevice

        if [[ "$cdevice" = "u" ]]
            then
                #cryptdevice=uuid=$(/sbin/blkid | /bin/grep 'sda2' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)
                blkid

                cryptdevice=/dev/disk/by-uuid/$(/sbin/blkid | /bin/grep 'sda2' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)
                cryptroot=/dev/disk/by-uuid/$(/sbin/blkid | /bin/grep 'main-root' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)
                cryptswap=/dev/disk/by-uuid/$(/sbin/blkid | /bin/grep 'main-swap' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)

        else
                cryptdevice="/dev/sda2"
                cryptroot="/dev/mapper/main-root"
                cryptswap="/dev/mapper/main-swap"

                sleep 1
        fi


        echo ""
        echo "cryptdevice:"$cryptdevice
        echo "cryptroot:  "$cryptroot
        echo "cryptswap:  "$cryptswap

        sleep 1

        echo "timeout 3" > /boot/loader/loader.conf
        echo "default 01_arch.conf" >> /boot/loader/loader.conf
        #echo "arch-lts" >> /boot/loader/loader.conf

        echo "title Arch Linux" > /boot/loader/entries/01_arch.conf
        echo "linux /vmlinuz-linux" >> /boot/loader/entries/01_arch.conf
        echo $line >> /boot/loader/entries/01_arch.conf
        echo "initrd /initramfs-linux.img" >> /boot/loader/entries/01_arch.conf
        echo "options $options cryptdevice=$cryptdevice:main root=$cryptroot resume=$cryptswap lang=de locale=de_DE.UTF-8 rw" >> /boot/loader/entries/01_arch.conf
        echo "sort-key 1" > /boot/loader/entries/01_arch.conf


        cat /boot/loader/entries/01_arch.conf

        sleep 1

        echo "title Arch Linux fallback" > /boot/loader/entries/02_arch-fallback.conf
        echo "linux /vmlinuz-linux" >> /boot/loader/entries/02_arch-fallback.conf
        echo $line >> /boot/loader/entries/02_arch-fallback.conf
        echo "initrd /initramfs-linux-fallback.img" >> /boot/loader/entries/02_arch-fallback.conf
        echo "options $options cryptdevice=$cryptdevice:main root=$cryptroot resume=$cryptswap lang=de locale=de_DE.UTF-8 rw" >> /boot/loader/entries/02_arch-fallback.conf
        echo "sort-key 2" > /boot/loader/entries/02_arch-fallback.conf

        cat /boot/loader/entries/02_arch-fallback.conf

        sleep 1


        echo "title Arch Linux lts" > /boot/loader/entries/03_arch-lts.conf
        echo "linux /vmlinuz-linux-lts" >> /boot/loader/entries/03_arch-lts.conf
        echo $line >> /boot/loader/entries/03_arch-lts.conf
        echo "initrd /initramfs-linux-lts.img" >> /boot/loader/entries/03_arch-lts.conf
        echo "options $options cryptdevice=$cryptdevice:main root=$cryptroot resume=$cryptswap lang=de locale=de_DE.UTF-8 rw" >> /boot/loader/entries/03_arch-lts.conf
        echo "sort-key 3" > /boot/loader/entries/03_arch-lts.conf

        cat /boot/loader/entries/03_arch-lts.conf

        sleep 1

        echo "title Arch Linux lts fallback" > /boot/loader/entries/04_arch-lts-fallback.conf
        echo "linux /vmlinuz-linux-lts" >> /boot/loader/entries/04_arch-lts-fallback.conf
        echo $line >> /boot/loader/entries/04_arch-lts-fallback.conf
        echo "initrd /initramfs-linux-lts-fallback.img" >> /boot/loader/entries/04_arch-lts-fallback.conf
        echo "options $options cryptdevice=$cryptdevice:main root=$cryptroot resume=$cryptswap lang=de locale=de_DE.UTF-8 rw" >> /boot/loader/entries/04_arch-lts-fallback.conf
        echo "sort-key 4" > /boot/loader/entries/04_arch-lts-fallback.conf

        cat /boot/loader/entries/04_arch-lts-fallback.conf

        sleep 1

}

read -r -p "Please choose [1 - 6] " response

if [[ "$response" = "1" ]]
    then

        #check if online
        ping -c 1 -W 0.7 1.1.1.1 > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
                echo "Onlinecheck: OK"
        else
                echo "You are offline. You can use: iwctl --passphrase passphrase station device connect SSID "
                exit
        fi

        gdisk /dev/sda

        read -r -p "Do you want to create an encrypted LVM? [Y/n] " response
        if [[ "$response" =~ ^([nN])+$ ]]
        then
                encrypted=false
                dev="/dev/main/"
                echo "Creating LVM"
                sleep 3

                pvcreate /dev/sda2
                vgcreate main /dev/sda2
        else
                encrypted=true
                dev="/dev/mapper/main-"
                echo "Creating encrypted LVM"
                sleep 3
                cryptsetup -y -v luksFormat /dev/sda2
                cryptsetup luksOpen /dev/sda2 lvm

                pvcreate /dev/mapper/lvm
                vgcreate main /dev/mapper/lvm

        fi




        read -r -p "Please choose the size of swap in GB: (4 or 8) " swapsize

        if [[ $swapsize -gt 4 ]]
        then
                lvcreate -L 8G -n swap main
        else
                lvcreate -L 4G -n swap main
        fi



        #clear


        read -r -p "Do you want to have a seperate /home partiton and create a minimum 20GB root partion?  [y/N] " response2
        if [[ "$response2" =~ ^([nN])+$ ]]
        then
                echo "everything goes to /"
                sleep 3
                lvcreate -l 80%FREE -n root main

                mkfs.ext4 /dev/mapper/main-root
                mount /dev/mapper/main-root /mnt

        else

                echo "creating sperate homedir and /"
                sleep 3
                echo ""
                read -r -p "Please choose the size of root in GB: " rootsize
                if [[ $rootsize -gt 20 ]]
                then
                    echo "creating root with $rootsize GB now"
                    rootsize+="GB"
                    lvcreate -L $rootsize -n root main

                else
                    echo "creating root with 20 GB now"
                    lvcreate -L 20GB -n root main
                fi

                mkfs.ext4 /dev/mapper/main-root
                mount /dev/mapper/main-root /mnt

                # lvcreate -L 10GB -n var main
                # mkfs.ext4 /dev/mapper/main-var
                # mkdir /mnt/var
                # mount /dev/mapper/main-var /mnt/var

                lvcreate -l 80%FREE -n home main
                mkfs.ext4 /dev/mapper/main-home
                mkdir /mnt/home
                mount /dev/mapper/main-home /mnt/home


        fi


        echo "Showing LVM layout:"
        echo ""

        lvdisplay

        sleep 3

        mkfs.vfat -F32 /dev/sda1
        mkdir /mnt/boot
        mount /dev/sda1 /mnt/boot
        mkswap /dev/mapper/main-swap
        swapon /dev/mapper/main-swap

        #pacman -S wget

        #clear

        #lsblk -f

        read -r -p "Do you use your own mirror? [y/N] " response3
        if [[ "$response3" =~ ^([yY])+$ ]]
        then
                curl -o /etc/pacman.d/mirrorlist "https://archlinux.org/mirrorlist/?country=DK&protocol=https&ip_version=4"
                #reflector --country Germany,Denmark --protocol https --sort rate --save /etc/pacman.d/mirrorlist

                echo "## local mirrorlist  $(date)" >> /etc/pacman.d/mirrorlist
                sudo echo "Server = http://192.168.5.222/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

        else

                curl -o /etc/pacman.d/mirrorlist "https://archlinux.org/mirrorlist/?country=DK&protocol=https&ip_version=4"
                //reflector --country Germany,Denmark --protocol https --sort rate --save /etc/pacman.d/mirrorlist




        fi



        nano /etc/pacman.d/mirrorlist

        cp /etc/pacman.d/mirrorlist ./mymirrorlist

        echo "We need the updated keyring first.."
        sleep 3

        pacman -Sy archlinux-keyring

        sleep 3

        pacstrap /mnt base base-devel linux linux-headers linux-firmware nano networkmanager cryptsetup lvm2 device-mapper sysfsutils wget
        genfstab -U /mnt > /mnt/etc/fstab


        #check if a seperate luks home partition exists
        HOMEDIR_STATUS=$(cryptsetup status main-home | head -n 1)
        if [[ $HOMEDIR_STATUS != *"inactive"* ]]
        then

            echo "A seperate homedir partition exists on your filesystem."
            # echo "A seperate homedir partition exists on your filesystem. Creating a fstab entry"
            # echo "/dev/mapper/main-home     /home       ext4        defaults    0 0"  >> /mnt/etc/fstab
            # echo ""
            # sleep 5
        fi

        cp mymirrorlist /mnt/etc/pacman.d/mirrorlist

        cp -v $0 /mnt/

        echo "Chrooting now. Please call $0 and goto step 2."

        sleep 3

        arch-chroot /mnt/



elif [[ "$response" = "2" ]]
    then


        #check if online
        ping -c 1 -W 0.7 1.1.1.1 > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
                echo "Onlinecheck: OK"
        else
                echo "You are offline. You can use: nmcli dev wifi connect SSID password PASSWORD or"
                echo "iwctl --passphrase passphrase station device connect SSID"
                exit
        fi



        sleep 1

        echo ""
        read -r -p "Please choose a hostname: " hostname
        echo $hostname > /etc/hostname

        cat /etc/hostname

        sleep 5

        echo "LANG=de_DE.UTF-8" > /etc/locale.conf
        cat /etc/locale.conf


        echo "KEYMAP=de-latin1" > /etc/vconsole.conf
        cat /etc/vconsole.conf

        ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

        #cat /etc/localtime

        echo "Writing german locale to /etc/locale.gen"
        sleep 3

        #sed -i '/de_DE/s/^# //g' /etc/locale.gen

        echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
        echo "de_DE ISO-8859-1" >> /etc/locale.gen
        echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
        nano /etc/locale.gen



        locale-gen

        echo "passwd root"
        sleep 1

        passwd

        echo "base udev autodetect modconf block keyboard keymap encrypt lvm2 filesystems resume fsck)" >> /etc/mkinitcpio.conf

        nano /etc/mkinitcpio.conf


        read -r -p "Do you want to run mkinitcpio -p linux? [y/N] " response
        if [[ "$response" =~ ^([nN])+$ ]]
        then
                echo "skipping..."
        else
                echo "Creating images"
                sleep 1
                mkinitcpio -p linux
        fi


        read -r -p "Do you want to use [s]ystemd-boot or [g]rub? " responsegrub
        if [[ "$responsegrub" = "g" ]]
        then
              echo "GRUB installation"
              sleep 3

              read -r -p "Please choose cryptdevice: [u]uid or /[d]ev/sda2 " cdevice

              if [[ "$cdevice" = "u" ]]
                  then
                      #cryptdevice=uuid=$(/sbin/blkid | /bin/grep 'sda2' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)
                      blkid

                      cryptdevice=/dev/disk/by-uuid/$(/sbin/blkid | /bin/grep 'sda2' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)
                      cryptroot=/dev/disk/by-uuid/$(/sbin/blkid | /bin/grep 'main-root' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)
                      cryptswap=/dev/disk/by-uuid/$(/sbin/blkid | /bin/grep 'main-swap' | /bin/grep -o -E ' UUID="[a-zA-Z|0-9|\-]*' | /bin/cut -c 8-)

              else
                      cryptdevice="/dev/sda2"
                      cryptroot="/dev/mapper/main-root"
                      cryptswap="/dev/mapper/main-swap"

                      sleep 1
              fi


              mount -t efivarfs efivarfs /sys/firmware/efi/efivars
              pacman -S grub efibootmgr dosfstools
              echo "cryptdevice=$cryptdevice:main root=/dev/mapper/main-root resume=$cryptswap lang=de locale=de_DE.UTF-8" >> /etc/default/grub
              nano /etc/default/grub



              grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug

              sleep 3

              grub-mkconfig -o /boot/grub/grub.cfg



        else
              echo "bootctl installation"
              sleep 3
              systemd-machine-id-setup
              bootctl install
              generateEFIentries
        fi



        systemctl enable NetworkManager



        echo "Almost ready to reboot, please remove installation media"
        echo "Please exit chroot, umount /mnt(/boot) and reboot."

        sleep 3


        exit

        umount /mnt/boot
        umount /mnt


elif [[ "$response" = "3" ]]
    then



        #check if online
        ping -c 1 -W 0.7 1.1.1.1 > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
                echo "Onlinecheck: OK"
        else
                echo "You are offline. You can use: nmcli dev wifi connect SSID password PASSWORD or"
                echo "iwctl --passphrase passphrase station device connect SSID"
                exit
        fi

        sleep 3
        clear


        echo "Create new user, set password and open etc/sudoers"
        echo ""

        read -r -p "Please choose a username: " username

        sleep 1

        useradd -m -g users -s /bin/bash $username

        gpasswd -a $username wheel

        passwd $username



        nano /etc/sudoers



        #clear

        echo "Now you can enable pacmans multiple download option"
        sleep 5
        nano /etc/pacman.conf

        #pacman -S linux-lts

        read -r -p "What DE to use: [k]de, [g]nome, [b]udgie, [c]innamon, [d]eepin or [n]one? " de


        if [[ "$de" = "k" ]]
            then


                echo "Installing xorg, xorg-init"

                sleep 1

                pacman -S xorg-server xorg-xinit

                echo "Installing Plasma sddm ..."

                sleep 1

                pacman -S plasma sddm sddm-kcm linux-lts --noconfirm
                localectl set-x11-keymap de pc105 nodeadkeys
                pacman -S ttf-dejavu konsole dolphin pacman-contrib inter-font --noconfirm
                systemctl enable sddm


                echo "Installing common software now"

                pacman -S firefox firefox-i18n-de thunderbird filezilla gimp inkscape vlc okular gwenview filelight git ark kate

        elif [[ "$de" = "c" ]]
            then

                echo "Installing xorg, xorg-init"

                sleep 1

                pacman -S xorg-server xorg-xinit

                echo "Installing cinnamon ..."

                sleep 1

                pacman -S cinnamon nano cinnamon-translations linux-lts --noconfirm
		pacman -S system-config-printer gnome-keyring gnome-terminal blueberry metacity lightdm lightdm-gtk-greeter

                #localectl set-x11-keymap de pc105 nodeadkeys
                systemctl enable lightdm




        elif [[ "$de" = "g" ]]
            then

                echo "Installing Gnome"
                sleep 1

                pacman -S gnome --noconfirm
                localectl set-x11-keymap de pc105 nodeadkeys
                pacman -S firefox firefox-i18n-de baobab git evolution linux-lts


                systemctl enable gdm



        elif [[ "$de" = "b" ]]
            then

                echo "Installing Budgie"
                sleep 1

                pacman -S budgie-desktop gnome gnome-control-center --noconfirm
                systemctl enable gdm

        elif [[ "$de" = "d" ]]
            then

                echo "Installing Deepin"
                sleep 1

                pacman -S deepin deepin-extra lightdm-deepin-greeter lightdm
                systemctl enable lightdm


        elif [[ "$de" = "n" ]]
            then

                echo "You can install DM manually"
                sleep 1


        fi


        echo "Creating paccache hook"
        mkdir /etc/pacman.d/hooks
        echo "[Trigger]
Operation = Upgrade
Operation = Install
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache
When = PostTransaction
Exec = /sbin/paccache -rk1" > /etc/pacman.d/hooks/paccache.hook



        pacman -S pacman-contrib


        echo "creating aur & shares"

        cd /home/steffen

        curl 192.168.5.222/images/nasmount.sh > nasmount.sh

        mkdir share
        mkdir share/webdata
        mkdir share/data
        mkdir aur

        cd aur
        
        git clone https://aur.archlinux.org/visual-studio-code-bin.git
        git clone https://aur.archlinux.org/brave-bin.git







        echo ""
        echo "Thats it. You can reboot now..."


elif [[ "$response" = "4" ]]
    then

        blkid

        echo ""
        echo "Trying to decrypt disk by using /dev/sda2.."
        sleep 1
        echo "cryptsetup luksOpen /dev/sda2 main"
        sleep 1


        cryptsetup luksOpen /dev/sda2 main
        sleep 1


        #lsblk

        read -r -p "Do you want to mount the drive and arch-chroot? [y/N] " response
        if [[ "$response" =~ ^([nN])+$ ]]
        then
                lsblk
        else
                mount /dev/mapper/main-root /mnt
                mount /dev/mapper/main-var /mnt/var
                mount /dev/mapper/main-home /mnt/home
                mount /dev/sda1 /mnt/boot
                arch-chroot /mnt/

        fi


elif [[ "$response" = "5" ]]
    then

        cp -rv /boot/loader/entries/ /tmp
        generateEFIentries



elif [[ "$response" = "6" ]]
    then
        sed 's/sda/nvme0n1p/g' $0 > arch_nvm_install.sh

elif [[ "$response" = "7" ]]
    then

        lsblk
        echo ""

        read -r -p "Please choose a device: /dev/" device
        sed 's/sda/'$device'/g' $0 > archinstall2.sh
        echo ""
        sh archinstall2.sh

elif [[ "$response" = "8" ]]
    then
        setfont /usr/share/kbd/consolefonts/ter-k32b.psf.gz

elif [[ "$response" = "9" ]]
    then
        lsblk
        echo ""
        read -r -p "Please choose a device: /dev/" device
        cryptsetup open --type plain -d /dev/urandom /dev/$device to_be_wiped
        clear
        lsblk
        echo "writing zeros now"
        sleep 3
        dd if=/dev/zero of=/dev/mapper/to_be_wiped status=progress
        echo "umount to_be_wiped"
        cryptsetup close to_be_wiped


fi
