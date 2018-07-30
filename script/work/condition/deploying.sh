ntos Version checking
clear
system=`cat /etc/redhat-release`
Version=`cat /etc/redhat-release | awk '{print $4}'`
Version_num=`awk -v a=$Version -v b=7 'BEGIN{print(a>b)?"0":"1"}'`

check(){
if [ $? -eq 0 ]; 
 then

    echo $var-------------------- ok

 else
    echo $var--------------------flase
    exit 2
fi
}


##numal##########################################################################################################################################
##------------------------------------------numal-----------------------------------------------------------------------------------------#######


dns(){
var=`printf "DNS"`
echo nameserver 114.114.114.114 >> /etc/resolv.conf
check
}


appinstall(){
var=`printf "app installed"`
yum install -y parted lsscsi telnet bc nc lsof sysstat  bind-utils tmpwatch smartmontools python-setuptools vim ntpdate >/dev/null
check
}



#############################################################################################################################################
##-----------------------------------------centos7------------------------------------------------------------------------------------#######

LANG7(){
var=`printf "Lanager"`
echo "LANG=en_US.utf8
LC_CTYPE=en_US.utf8">/etc/locale.conf
check
}

firewalld(){

active=`systemctl status firewalld |grep Active|awk '{print $3}'`

case $active in
        "(dead)")
                var=`printf "Firewalld have been stop "`
                ;;


        "(running)")

                `systemctl stop firewalld`&&`systemctl disable firewalld`>/dev/null
                var=`printf "To stop firewalld"`
                ;;


        *)
                echo unknown firewalld status
                exit 3

esac

check
}



selinux_config(){
var=`printf "To stop Selinux"`
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux&&setenforce 0
check
}

NetworkManager_config(){
active=`systemctl status NetworkManager |grep Active|awk '{print $3}'`

case $active in
        "(dead)")
                var=`printf "NetworkManager have been stop "`
                ;;


        "(running)")

                `systemctl stop NetworkManager`&&`systemctl disable NetworkManager`>/dev/null
                var=`printf "To stop NetworkManager"`
                ;;


        *)
                echo unknown NetworkManager status
                exit 3

esac

check
}

ssh_config(){

var=`printf "ssh_fonfig"`
sed -i 's/#Port 22/Port 65422/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
check

}





##############################################################################################################################################

##---------------------------------------centos6----------------------------------------------------------------------########################

LANG6(){
echo"
LANG="en_US.UTF-8"
SYSFONT="latarcyrheb-sun16"">/etc/sysconfig/i18n
}

##
##############################################################################################################################################
##--------------------------------------MENU---------------------------------------------------------------------------#######################
menu(){
cat << EOF
----------------------------------------------------------------------
|          ~~~~~~Deploying the underlying environment~~~~            |
|       `echo "Systeam Version is $system"`     |
----------------------------------------------------------------------
EOF
}



################################################################################################################################################
##-----------------------------------script start ------------------------------------------------------------------------######################
menu

if [ $Version_num -eq 0 ];
 then
dns
LANG7
firewalld
appinstall
selinux_config
NetworkManager_config
ssh_config
fi 
