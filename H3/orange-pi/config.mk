# toolchain directory, $TOOLCHAIN/bin/arm-eabi-gcc should exist
TOOLCHAIN = /opt/gcc-arm-8.2-2019.01-x86_64-arm-eabi

# PXE server IP (do not use hostname here)
PXE_SERVER = 192.168.11.116

# where to scp the binaries to
PXE_DEST = root@$(PXE_SERVER):/var/tftpboot

# the same directory relative (as a TFTP client would see it)
PXE_DIR = pxe/arm

