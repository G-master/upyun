#!/bin/bash
i=1

disk()
{
        clear

        disk_info=`fdisk  -l |grep ^Disk.*/|awk -F '[,]' '{print $1}'|sort -n`
        echo "===-System-Disk-info-==="
        echo "------------------------"
        echo "$disk_info"
}
disk
function usage() {
    echo "Usage: format [OPTIONS]"
    echo ""
    echo "  --disk-size:   { format the disk depend on size[GB] "
    echo "  --mount-file:  mount point name, path like /disk/[sata/ssd]"
    echo "  --fs: filesystem type, ext4 or xfs |~defualt: XFS"
    echo "  --sys-disk {Select your system disk to prevent formatting |~default:  /dev/sda  }"
    echo "  --help: help message"
    echo ""
    exit 1
}

TEMP=$(getopt -o : --long disk-size:,mount-path:,fs:,sys-disk:,help -- "$@")
eval set  -- "$TEMP" 

[ $# = 0 ] && usage


while true
do
    case $1 in 
        --disk-size)
            size=$2; shift 2 ;;
        --mount-path)
            file=$2; shift 2 ;;
        --fs)
            fs=$2; shift 2 ;;
    --sys-disk)
        sysdisk=$2; shift 2 ;;
        --)
          shift ; break ;;
        --help|*)
            usage ;;
    esac
done

#if [ -z $1 ];then
#
#    echo "----------------------------------"
#    printf "\033[36;5mNo user parameters are received...\033[0m"
#    echo ""
#    echo "----------------------------------"
#else
    if [[ -z ${file} ]]; then
            echo "----------------------------------"
            printf "\033[36;5mNeed a Mount Path...\033[0m"
            echo ""
            echo "----------------------------------"
            usage
    elif [[ ${file} != /disk/sata && ${file} != /disk/ssd ]]; then
            echo "-----------------------------------------"
            printf "\033[36;5mYour Mount Path is Non conformity...\033[0m"
            echo ""
            echo "-----------------------------------------"
            usage
    fi
    if [ -z $sysdisk ];then

            sysdisk="/dev/sda"

    fi

    if [ -z ${fs} ]; then

        fs="xfs"
            echo "-----------------------------------------"
        printf "\033[34;5mFilesystem type will be XFS!!...\033[0m"
            echo ""
            echo "-----------------------------------------"
        #    read -p "filesystem type will be XFS!! [y/n]" ask
        #   case ${ask} in
            #   y|yes)
            #       break;;
            #   n|*)
            #       usage;;
        #   esac

    fi



 
#fi

num=`fdisk  -l |grep $size |wc -l`
num=$(($num+1))
while [[ $i -ne $num ]]
do

disk=`fdisk -l |grep $size | awk -F'[ :]+' '{ if($2!="/dev/sda")print $2}'|sed -n $i\p`


fdisk $disk <<FDISK
u
d

d

d
 
d
n
p
1


w
FDISK

if [ -d ${file}$i ] 
then
    rm -rf ${file}$i
else 
    mkdir -p ${file}$i
fi

case ${fs} in

  xfs)
        
        mkfs.xfs -f $disk"1" && xfs_admin -L ${file}$i $disk"1"
        if [ $? -eq 0 ];then
             printf "\033[32;5m$disk"1" has been formatted To XFS...\033[0m"
             echo ""
             echo "mkdir -p ${file}$i;mount -L ${file}$i -o noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M ${file}$i
">>/etc/rc.local
        fi;;
 ext4)
        mkfs.ext4 -T largefile $disk"1" && e2label $disk"1" ${file}$i
         if [ $? -eq 0 ];then
                         printf "\033[32;5m$disk"1" has been formatted To EXT4...\033[0m"
                         echo ""
                         echo "mkdir -p ${file}$i;mount -L ${file}$i -o defaults,noatime,nodiratime,barrier=0,discard ${file}$i
">>/etc/rc.local
         fi;;
    *)
        printf "\033[31;5mUnknow filesystem type...\033[0m"
        echo ""
        echo "Please $0 --help" 
        exit;;

esac

i=$(($i+1))
done

if [ $? -eq 0 ];then

    printf "\033[32;5mAll of the hard disk have been formatted ...\033[0m"
    echo ""
    if [ -x /etc/rc.local ];then
    source /etc/rc.local
    exit 0
    else
    chmod +x /etc/rc.local && source /etc/rc.local
    exit 0
    fi
else
printf "\033[31;5m All of the hard disk have go die...\033[0m"
    echo ""    
fi

