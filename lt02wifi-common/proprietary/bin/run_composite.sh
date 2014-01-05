#!/system/bin/sh

setprop sys.telephonymoduleloglevel 8

MODULE_DIR=/system/lib/modules
insmod $MODULE_DIR/cploaddev.ko
insmod $MODULE_DIR/seh.ko
# load cp and mrd image and release cp
/system/bin/cploader

ret="$?"


if [ ! -e $NVM_ROOT_DIR ]; then
	mkdir -p $NVM_ROOT_DIR
	chown system.system $NVM_ROOT_DIR
fi

if [ ! -e $MARVELL_RW_DIR ]; then
	mkdir -p $MARVELL_RW_DIR
	chown system.system $MARVELL_RW_DIR
	chmod 0755 $MARVELL_RW_DIR
fi

cputype=`cat /sys/devices/system/cpu/cpu0/cputype`


case "$ret" in
	    "-1")
		rmmod seh
		rmmod cploaddev
		stop ril-daemon
		exit
       ;;
	    "1")
		rmmod seh
		rmmod cploaddev
		stop ril-daemon
		start nvm-aponly
		start diag-aponly
		insmod $MODULE_DIR/citty.ko
		start atcmdsrv-aponly
		exit
       ;;
       *)
       ;;
esac

fastdormancytimeout=`getprop persist.radio.fastdorm.timeout`
if [ -z "$fastdormancytimeout" ]; then
	case "$cputype" in
            "pxa986ax"|"pxa986zx")
	    setprop persist.radio.fastdorm.timeout 5
	    ;;
            "pxa988ax"|"pxa988zx")
	    setprop persist.radio.fastdorm.timeout 0
	    ;;
	    *)
	    setprop persist.radio.fastdorm.timeout 0
	    ;;
	esac
fi

# $1 src file
# $2 dst file
function copy_if_not_exist()
{
if [ -f "${2}" ]; then
	echo "existing ${2}";
else
	if [ -f "${1}" ]; then
		cp ${1} ${2}
		chmod 666 ${2}
		chown system.system ${2}
		echo "cp: ${1} -> ${2}"
	fi
fi
}

copy_if_not_exist "/etc/tel/${rfcfg_src}" "${NVM_ROOT_DIR}/${rfcfg_dst}"

insmod $MODULE_DIR/msocketk.ko
insmod $MODULE_DIR/citty.ko
insmod $MODULE_DIR/cci_datastub.ko
insmod $MODULE_DIR/ccinetdev.ko
insmod $MODULE_DIR/gs_modem.ko
insmod $MODULE_DIR/diag.ko
insmod $MODULE_DIR/gs_diag.ko
insmod $MODULE_DIR/cidatattydev.ko

ln -s /dev/ttymodem0 /dev/ttyGS0
ln -s /dev/citty11 /dev/umts_router

start eeh
start nvm
start diag
start atcmdsrv
start vcm
