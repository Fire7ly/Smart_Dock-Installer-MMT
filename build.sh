#!/bin/bash

# All the source code of module templet and Smart Dock launcher is subjected to their respective owners...
# This is the simple bash script to build Smart Dock Module just run it and get you module zip 
# in same directory where this script present, this script made in that hope it will helpfull to 
# save time and give us a flashable module.
# Author: Fire7ly
# Telegram: @Fire7ly



#set env var
os=$(hostnamectl | grep "Operating System" | cut -f 2 -d ":" )
zip=$(which zip)
git=$(which git)
repo="https://github.com/Fire7ly/Smart_Dock-Installer-MMT.git"
out_zip=$(echo $repo | cut -d '/' -f 5 | sed 's/git/zip/g')
tmpdir='/tmp/Smart_Dock-Installer-MMT'
here=${PWD}
log=$(echo $0 | sed 's/sh/log/g')


#install dependencies
install_dep () {

    # install dependencies according to os
    if [[ $os == *"Arch"* ]]; then
        echo -e "Current system is $os...\n"
        if [ -f $zip ] && [ -f $git ]; then 
            echo "All Set ..."
        else
            if check_net; then 
                [ ! -f $zip ] && sudo pacman -Sy zip
                [ ! -f $git ] && sudo pacman -Sy git
            fi
        fi
    elif [[ $os == *"Ubuntu"* ]]; then
        echo -e "Current system is $os...\n"
        if [ -f $zip ] && [ -f $git ]; then 
            echo "All Set ..."
        else
            if check_net; then
                [ ! -f $zip ] && sudo apt install zip
                [ ! -f $git ] && sudo apt install git
            fi
        fi
    else
        echo -e "Can not find current system os flavour...\nplease install zip and git if not installed!"
    fi
}

check_net () {
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
        return 0
    else
        echo "Please Check Your Internet Connection..."
        exit 0
    fi
}

#list of necessary files for modules...
necessary_files=$(echo "
./system/priv-app/SmartDock/SmartDock.apk
./system/etc/permissions/cu.axel.smartdock.xml
./META-INF/com/google/android/update-binary
./META-INF/com/google/android/updater-script
./uninstall.sh
./module.prop
./customize.sh
./common/uninstall.sh
./common/install.sh
./common/addon/placeholder
./common/upgrade.sh
./common/functions.sh")

# Banner
banner() {

    echo -e "|--------------------------------------------------|"
    echo -e "|      Smart Dock Magisk Module Maker Script       |"
    echo -e "|             Made With ❤️  By @Fire7ly             |"
    echo -e "|--------------------------------------------------|\n"
}

#checking all files present
check_integrity () {

    for file in $necessary_files; do
        if [ ! -f $file ]; then 
            echo -e "$file Missing ..."
            return 1
        fi
    done

}


#Backup Plan :)
# If any files missing then clone from git and build module ...
build () {
    if [ $? = 1 ]; then
        [ -f $tmpdir ] && rm -rf $tmpdir
        echo -e "Cooking Module From Git Repo ...\n"
        if check_net; then
            git clone $repo $tmpdir 2>&1 > /dev/null
            cd $tmpdir && zip -r9 $out_zip * 2>&1 > /dev/null 
            cd $here && [ -f $tmpdir/$out_zip ] && mv $tmpdir/$out_zip $here 
            rm -rf $tmpdir
        fi
    else
        echo -e "All Necessary Files Present Cooking Module ...\n"
        [ -f $out_zip ] && rm -rf $out_zip
        zip -r9 $out_zip $necessary_files 2>&1 > /dev/null
    fi

}

#where all goes started...
main () {
    clear
    banner
    install_dep
    check_integrity
    build
    [ -f $out_zip ] && echo -e "Your Zip Here $here/$out_zip\n"
}


main | tee $log