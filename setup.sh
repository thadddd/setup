#! /usr/bin/bash

# Setup for warTruck

#####
# Pre-Run
#####


#####
# Variables
#####

s='sudo'
rtn='cd /home/setup'
home=/home/setup
conf=/home/setup/conf
suin='sudo aptitude install -y'
suinn='sudo aptitude install'
STEP=0
package=(mokutil build-essential bc dkms libelf-dev rfkill iw cmake libusb-1.0-0-dev scons libncurses-dev python-dev pps-tools git-core asciidoctor python3-matplotlib manpages-dev pkg-config python3-distutils ncurses-dev gnuplot libusb-dev python3-serial libcxx-serial-dev make gcc g++ libbluetooth-dev python3-numpy python3-qtpy wireshark wireshark-dev libwireshark-dev libmosquitto-dev git libwebsockets-dev zlib1g-dev libnl-3-dev libnl-genl-3-dev libcap-dev libpcap-dev libnm-dev libdw-dev libsqlite3-dev libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler libsensors4-dev python3 python3-setuptools python3-protobuf python3-requests python3-usb python3-dev python3-websockets librtlsdr0 libubertooth-dev libbtbb-dev)


#####
# Support Functions
#####

gps(){
    $rtn;
    wget http://download.savannah.gnu.org/releases/gpsd/gpsd-3.25.tar.gz;
    tar -xzf gpsd-3.25.tar.gz;
    cd gpsd-3.25 || return;
    export PYTHONPATH=/usr/local/lib/python3/dist-packages/;
    $s scons target_python=python3.9;
    $s scons check target_python=python3.9;
    $s scons install target_python=python3.9;
    $s cp /etc/default/gpsd /etc/default/gpsd.bk;
    $s cp $conf/gpsd /etc/default/gpsd;
    $s systemctl enable gpsd;
    $s systemctl enable gpsd.socket;
    $s service gpsd start;
    menu;
}

rtl(){
    $rtn;
    git clone git://osmocom.org/rtl-sdr.git;
    cd rtl-sdr || return;
    mkdir build;
    cd build || return;
    $s cmake ../ -DINSTALL_UDEV_RULES=ON;
    $s make && $s make install;
    ldconfig;
    $s cp ../rtl-sdr.rules /etc/udev/rules.d/;
    $s cp $conf/blacklist-dvb.conf /etc/modprobe.d/blacklist-dvb.conf;
    menu;
}

wifi(){
    $rtn;
    git clone https://github.com/morrownr/8812au-20210629.git;
    cd 8812au-20210629 || return;
    ./install-driver.sh;
    $rtn;
    git clone https://github.com/morrownr/88x2bu-20210702.git;
    cd 88x2bu-20210702 || return;
    ./install-driver.sh;
    $rtn;
    git clone https://github.com/morrownr/8814au.git;
    cd 8814au || return;
    ./install-driver.sh;
    menu;
}

uber(){
    $rtn;
    wget https://github.com/greatscottgadgets/libbtbb/archive/2020-12-R1.tar.gz -O libbtbb-2020-12-R1.tar.gz;
    tar -xf libbtbb-2020-12-R1.tar.gz;
    cd libbtbb-2020-12-R1 || return;
    mkdir build;
    cd build || return;
    $s cmake ..;
    $s make;
    $s make install;
    $s ldconfig;
    $rtn;
    wget https://github.com/greatscottgadgets/ubertooth/releases/download/2020-12-R1/ubertooth-2020-12-R1.tar.xz;
    tar -xf ubertooth-2020-12-R1.tar.xz;
    cd ubertooth-2020-12-R1/host || return;
    $s mkdir build;
    cd build || return;
    $s cmake ..;
    $s make;
    $s make install;
    $s ldconfig;
#    $rtn;
#    cd libbtbb-2020-12-R1/wireshark/plugins/btbb || return;
#    $s mkdir build;
#    cd build || return;
#    $s cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu/wireshark/libwireshark3/plugins ..;
#    $s make
#    $s make install
#    $rtn;
#    cd libbtbb-2020-12-R1/wireshark/plugins/btbredr || return;
#    $s mkdir build
#    cd build || return;
#    $s cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu/wireshark/libwireshark3/plugins ..;
#    $s make;
#    $s make install;
    menu;
}

kism(){
    $rtn;
    git clone https://www.kismetwireless.net/git/kismet.git;
    cd kismet || return;
    ./configure;
    $s make;
    $s make suidinstall;
    $s usermod -aG kismet dddd;
    $s $conf/kismet.conf;
    menu; 
}

update(){
    $s apt update;
    $s apt dist-upgrade -y;
    $s apt full-upgrade -y;
    $s apt autoremove -y;
    $s chmod ugo+rwx /home/ -R;
#    mkdir -p /home/setup;
#    mkdir -p /home/setup/files;
    $s git config --global user.name "thadddd";
    $s git config --global user.email "jasonauthement@gmail.com";
    $s apt install -y linux-headers-$(uname -r) aptitude timeshift;
    $s timeshift --create;
    $suinn libelf-dev;
    $suinn wireshark-dev; 
    $suinn libpcap-dev; 
    $suinn libnm-dev; 
    $suinn libdw-dev; 
    $suinn libubertooth-dev; 
    $suinn libbtbb-dev;     
    pkgINST;
}

pkgINST(){
    for pkg in "${package[@]}"
        do
        echo "Checking for $pkg";
            if [ -f /usr/bin/"$pkg" ]
                then
                    echo "$pkg is already installed";
                    sleep 2;
                else
                    $suin "$pkg";
            fi
    done
    menu;
}


######
# Menu Functions
######

menu(){
    echo "XXXXXXXXXXXXXX";
    echo "XXXXXXXXXXXXXX";
    echo "1 - UPDATE";
    echo "2 - WIFI";
    echo "3 - GPSD";
    echo "4 - RTL-SDR";
    echo "5 - Ubertooth";
    echo "6 - Kismet";
    echo "9 - EXIT";
    read -p "Which Step ?" menans1;
        while true; do
            case $menans1 in
                1) STEP=1;
                    update;;
                2) STEP=2;
                    wifi;;
                3) STEP=3;
                    gps;;
                4) STEP=4;
                    rtl;;
                5) STEP=5;
                    uber;;
                6) STEP=6;
                    kism;;
                9) STEP=9;
                    exit 0;;
                *) echo -ne "WRONG ANSWER";
                    sleep 3;
                    menu;;
            esac
        done
}

menu
