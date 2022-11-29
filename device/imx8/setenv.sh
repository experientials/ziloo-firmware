bootcmd=run distro_bootcmd;run bsp_bootcmd
bootdelay=2
baudrate=115200
ethprime=eth0
loadaddr=0x40480000
arch=arm
cpu=armv8
board=ucm-imx8m-plus
board_name=ucm-imx8m-plus
vendor=compulab
soc=imx8m
mfgtool_args=setenv bootargs console=${console},${baudrate} rdinit=/linuxrc clk_ignore_unused 
kboot=booti 
bootcmd_mfg=run mfgtool_args;if iminfo ${initrd_addr}; then if test ${tee} = yes; then bootm ${tee_addr} ${initrd_addr} ${fdt_addr}; else booti ${loadaddr} ${initrd_addr} ${fdt_addr}; fi; else echo "Run fastboot ..."; fastboot 0; fi;
nandfit_part=yes
initrd_addr=0x43800000
initrd_high=0xffffffffffffffff
emmc_dev=2
sd_dev=1
jh_clk= 
 jh_mmcboot=setenv fdtfile ucm-imx8m-plus-root.dtb;setenv jh_clk clk_ignore_unused mem=2048MB; if run loadimage; then run mmcboot; else run jh_netboot; fi; 
jh_netboot=setenv fdtfile ucm-imx8m-plus-root.dtb; setenv jh_clk clk_ignore_unused mem=2048MB; run netboot; 
 mmc_boot=if mmc dev ${devnum}; then devtype=mmc; run scan_dev_for_boot_part; fi
boot_net_usb_start=usb start
usb_boot=usb start; if usb dev ${devnum}; then devtype=usb; run scan_dev_for_boot_part; fi
boot_efi_bootmgr=if fdt addr ${fdt_addr_r}; then bootefi bootmgr ${fdt_addr_r};else bootefi bootmgr;fi
boot_efi_binary=load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} efi/boot/bootaa64.efi; if fdt addr ${fdt_addr_r}; then bootefi ${kernel_addr_r} ${fdt_addr_r};else bootefi ${kernel_addr_r} ${fdtcontroladdr};fi
load_efi_dtb=load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}${efi_fdtfile}
efi_dtb_prefixes=/ /dtb/ /dtb/current/
scan_dev_for_efi=setenv efi_fdtfile ${fdtfile}; for prefix in ${efi_dtb_prefixes}; do if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${efi_fdtfile}; then run load_efi_dtb; fi;done;run boot_efi_bootmgr;if test -e ${devtype} ${devnum}:${distro_bootpart} efi/boot/bootaa64.efi; then echo Found EFI removable media binary efi/boot/bootaa64.efi; run boot_efi_binary; echo EFI LOAD FAILED: continuing...; fi; setenv efi_fdtfile
boot_prefixes=/ /boot/
boot_scripts=boot.scr.uimg boot.scr
boot_script_dhcp=boot.scr.uimg
boot_targets=usb0 mmc1 mmc2 
boot_syslinux_conf=extlinux/extlinux.conf
boot_extlinux=sysboot ${devtype} ${devnum}:${distro_bootpart} any ${scriptaddr} ${prefix}${boot_syslinux_conf}
scan_dev_for_extlinux=if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${boot_syslinux_conf}; then echo Found ${prefix}${boot_syslinux_conf}; run boot_extlinux; echo SCRIPT FAILED: continuing...; fi
boot_a_script=load ${devtype} ${devnum}:${distro_bootpart} ${scriptaddr} ${prefix}${script}; source ${scriptaddr}
scan_dev_for_scripts=for script in ${boot_scripts}; do if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${script}; then echo Found U-Boot script ${prefix}${script}; run boot_a_script; echo SCRIPT FAILED: continuing...; fi; done
scan_dev_for_boot=echo Scanning ${devtype} ${devnum}:${distro_bootpart}...; for prefix in ${boot_prefixes}; do run scan_dev_for_extlinux; run scan_dev_for_scripts; done;run scan_dev_for_efi;
scan_dev_for_boot_part=part list ${devtype} ${devnum} -bootable devplist; env exists devplist || setenv devplist 1; for distro_bootpart in ${devplist}; do if fstype ${devtype} ${devnum}:${distro_bootpart} bootfstype; then run scan_dev_for_boot; fi; done; setenv devplist
bootcmd_usb0=devnum=0; run usb_boot
bootcmd_mmc1=devnum=1; run mmc_boot
bootcmd_mmc2=devnum=2; run mmc_boot
distro_bootcmd=for target in ${boot_targets}; do run bootcmd_${target}; done
stdout=serial,vidconsole
stderr=serial,vidconsole
stdin=serial,usbkbd
autoload=off
scriptaddr=0x43500000
kernel_addr_r=0x40480000
bsp_script=boot.scr
image=Image
splashimage=0x50000000
console=ttymxc1,115200 console=tty1
fdt_addr_r=0x43000000
fdt_addr=0x43000000
boot_fdt=try
fdt_high=0xffffffffffffffff
boot_fit=no
fdtfile=ucm-imx8m-plus.dtb
bootm_size=0x10000000
mmcdev=0
mmcpart=1
mmcroot=/dev/mmcblk1p2 rootwait rw
mmcautodetect=yes
mmcargs=setenv bootargs ${jh_clk} console=${console} root=${mmcroot}
 loadbootscript=load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${bsp_script};
bootscript=echo Running bootscript from mmc ...; source
loadimage=load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}
loadfdt=load mmc ${mmcdev}:${mmcpart} ${fdt_addr_r} ${fdtfile}
mmcboot=echo Booting from mmc ...; run mmcargs; if test ${boot_fit} = yes || test ${boot_fit} = try; then bootm ${loadaddr}; else if run loadfdt; then booti ${loadaddr} - ${fdt_addr_r}; else echo WARN: Cannot load the DT; fi; fi;
netargs=setenv bootargs ${jh_clk} console=${console} root=/dev/nfs ip=dhcp nfsroot=${serverip}:${nfsroot},v3,tcp
netboot=echo Booting from net ...; run netargs;  if test ${ip_dyn} = yes; then setenv get_cmd dhcp; else setenv get_cmd tftp; fi; ${get_cmd} ${loadaddr} ${image}; if test ${boot_fit} = yes || test ${boot_fit} = try; then bootm ${loadaddr}; else if ${get_cmd} ${fdt_addr_r} ${fdtfile}; then booti ${loadaddr} - ${fdt_addr_r}; else echo WARN: Cannot load the DT; fi; fi;
emmc_root=/dev/mmcblk2p2
sd_root=/dev/mmcblk1p2
usb_root=/dev/sda2
usb_dev=0
boot_part=1
root_opt=rootwait rw
emmc_ul=setenv iface mmc; setenv dev ${emmc_dev}; setenv part ${boot_part};setenv bootargs console=${console} root=${emmc_root} ${root_opt};
sd_ul=setenv iface mmc; setenv dev ${sd_dev}; setenv part ${boot_part};setenv bootargs console=${console} root=${sd_root} ${root_opt};
usb_ul=usb start; setenv iface usb; setenv dev ${usb_dev}; setenv part ${boot_part};setenv bootargs console=${console} root=${usb_root} ${root_opt};
ulbootscript=load ${iface} ${dev}:${part} ${loadaddr} ${script};
ulimage=load ${iface} ${dev}:${part} ${loadaddr} ${image}
ulfdt=if test ${boot_fdt} = yes || test ${boot_fdt} = try; then load ${iface} ${dev}:${part} ${fdt_addr_r} ${fdtfile}; fi;
bootlist=sd_ul usb_ul emmc_ul
bsp_bootcmd=echo Running BSP bootcmd ...; for src in ${bootlist}; do run ${src}; env exist boot_opt && env exists bootargs && setenv bootargs ${bootargs} ${boot_opt}; if run ulbootscript; then run bootscript; else if run ulimage; then if run ulfdt; then booti ${loadaddr} - ${fdt_addr_r}; else if test ${boot_fdt} != yes; then booti ${loadaddr}; fi; fi; fi; fi; done; 
