# Allwinner H3 Bare Metal Examples

This repo contains simple, **experimental** code illustrating how to do a bare metal
programming on Allwinner H3/H2+ boards.
The code is tested on [OrangePi Zero][opizero] but should also work on NanoPi
Neo without any modification.

Some of the code was originally written by [dwelch67][dwelch67]. Some of the
code uses an astounding [H3 HAL library][lib-h3] from [Orange Pi DMX project][opidmx].

## Requisites

Download ARM toolchain for AArch32 bare metal from https://developer.arm.com/open-source/gnu-toolchain/gnu-a/downloads
and extract it e.g. into `/opt`:

```
$ wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2019.01/gcc-arm-8.2-2019.01-x86_64-arm-eabi.tar.xz
$ sudo tar -C /opt -xvf gcc-arm-8.2-2019.01-x86_64-arm-eabi.tar.xz
```

## Download & Build

To download and build all the examples, run:

```
$ git clone --depth=1 https://github.com/mprymek/allwinner-baremetal
$ cd allwinner-baremetal/H3/orange-pi
$ make
```

## Run Preparation

There are many ways how to load a built binary into the board but probably the most
convenient one is to use [U-Boot][u-boot] & TFTP.

If you are interested in this repo, you probably know how to install U-Boot into
your board. The most simple way is probably to use a standard Armbian SD card
and wipe out the Linux partition. If you want to dig deeper, you can
read my [blogpost about OrangePi netbooting][orangepi-netboot] or even build your
own U-Boot.

You must also install a TFTP server. Consult your OS manual on how to do it.

When you have these two things prepared, edit `config.mk` accordingly.

I will also suppose you have DHCP working in your LAN. If it's not the case, you
must configure static addresses in U-Boot which I will not describe here.
Consult U-Boot documentation.

## Running Manually

You can load the binary into your board using U-Boot shell. You can get into it by
pressing any key on `Hit any key to stop autoboot` U-Boot prompt.

At first, scp the built binary to your TFTP server (replace `192.168.1.100` with
your TFTP server IP address and edit the tftp directory if needed):

```
$ scp blinker01/allwinner-h3-blinker01.bin 192.168.1.100:/var/tftpboot/pxe/arm/
```

In the U-Boot shell, run:
```
=> dhcp
=> tftpboot 0x42000000 192.168.1.100:pxe/arm/allwinner-h3-blinker01.bin; go 0x42000000
```

The LED should now start to blink.

Note you must use the `go` command instead of `boot*` commands used to load the
Linux kernel. This is because we load a barebone binary and we don't want U-Boot
to do any magic, just jump to the given address where our binary is loaded.

## Running Automatically

You can configure your board to boot the given image automatically. To gain more
flexibility, we will place the U-Boot script on the TFTP server also. You will
need `mkimage` installed on your host computer to built the script image.
For Debian derivates, do:

```
sudo apt install u-boot-tools
```

At first, upload the binary to the TFTP server with:

```
$ make -C blinker01 install
```

This will copy the binary image and the boot script to your TFTP server. Then
make a symlink from the particular binary's load script to the general
`autoboot.scr`:

```
$ ssh root@my-tftp-server ln -s allwinner-h3-blinker01.scr /var/tftpboot/pxe/arm/autoboot.scr
```

By changing this symlink, you can choose which image to boot in the future.

Then you must change the command which U-Boot runs right after boot. Go to the
U-Boot shell and run:

```
=> setenv serverip 192.168.1.100
=> setenv scriptname pxe/arm/autoboot.scr
=> setenv scriptaddr 0x43100000
=> setenv bootcmd-old "$bootcmd"
=> setenv bootcmd 'dhcp; tftp ${scriptaddr} ${scriptname}; source ${scriptaddr}'
=> saveenv; reset
```

This (permanently) changes U-Boot configuration to run TFTP:pxe/arm/autoboot.scr
on reboot.

You can also configure the TFTP server IP using your DHCP server. In this case,
omit the `setenv serverip` line and put the TFTP server IP into the `next-server`
option of your DHCP configuration.

[opizero]: http://linux-sunxi.org/Xunlong_Orange_Pi_Zero
[u-boot]: https://www.denx.de/wiki/U-Boot
[orangepi-netboot]: http://blog.ator.cz/posts/orangepi-zero-netboot/
[dwelch67]: https://github.com/dwelch67
[lib-h3]: https://github.com/vanvught/rpidmx512/tree/master/lib-h3
[opidmx]: http://www.orangepi-dmx.org/
