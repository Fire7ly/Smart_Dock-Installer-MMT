#!/bin/bash

set -e
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
author="@Fire7ly"
var="v1.0"
download_base_url="https://raw.githubusercontent.com/Fire7ly/Smart_Dock-Installer-MMT/master"
download_url=""



# Check dependencies
chk_zip_git(){
    if [[ -f $zip &&  -f $git ]]; then 
        return 0
    else
        return 1
    fi
}

#show ver
show_ver(){
    echo "build.sh $var"
}


# Help section
show_help() {
cat << EOF
Usage: ./build.sh [OPTIONS]

A brief description of what the script does.

Options:
    -h, --help        Display this help and exit
    -v, --version     Output script version information and exit
    -c, --clean       Build Module from latest git repo
    -d, --dirty       Build module from Module repo without fetch latest build
EOF
}



#install dependencies
install_dep () {

    # install dependencies according to os
    echo -e "Current system is $os...\n"

    if [[ $os == *"Arch"* ]]; then
        if ! chk_zip_git; then 
            if check_net; then 
                [ ! -f $zip ] && sudo pacman -Sy zip
                [ ! -f $git ] && sudo pacman -Sy git
            fi
        fi
    elif [[ $os == *"Ubuntu"* ]]; then
        echo -e "Current system is $os...\n"
        if ! chk_zip_git; then
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
    if nc -zw1 google.com 443;  then
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

integrity_check_files=$(echo "
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

dirty_build_files=$(echo "
./system/priv-app/SmartDock/SmartDock.apk
./system/etc/permissions/cu.axel.smartdock.xml")

# clone and replace apk from latest git build
clean_build(){
    for file in ${necessary_files}; do
    
        if [ -f $file ]; then 
            rm -rf $file
        fi
        echo -e "Renewing : $file"
        fetch_single_file ${file}
        #########################################################################################
        # url="${download_base_url}/${file#./}"                                                 #
        # index=$(echo "$file" | grep -o '/' | wc -l)                                           #
        # final_dest=""                                                                         #
        # if [[ $index > 1 ]]; then                                                             #
        #     final_dest="${file%/*}"                                                           #
        #     curl --create-dirs -O --output-dir $final_dest $url 2>&1 > /dev/null              #
        # else                                                                                  #
        #     final_dest="${file#./}"                                                           #
        #     curl -o $final_dest $url 2>&1 > /dev/null                                         #
        # fi                                                                                    #
        #########################################################################################
    done
}

dirty_build(){
      
    if check_net; then
        for file in ${dirty_build_files}; do
            if [ -f $file ]; then
                rm -rf $file
            fi
            echo -e "Renewing : $file"
            fetch_single_file ${file}
        done
    fi
    
}

fetch_single_file(){
    local dest=$1
    url="${download_base_url}/${dest#./}"
    index=$(echo "$dest" | grep -o '/' | wc -l)
   final_dest=""
    if [[ $index > 1 ]]; then
        final_dest="${dest%/*}"
        curl --silent --create-dirs -O --output-dir $final_dest $url
    else
        final_dest="${dest#./}"
        curl --silent -o $final_dest $url
    fi
}

# Banner
banner() {

    echo -e "|--------------------------------------------------|"
    echo -e "|      Smart Dock Magisk Module Maker Script $var  |"
    echo -e "|             Made With ❤️  By $author             |"
    echo -e "|--------------------------------------------------|\n"
}

#checking all files present
check_integrity () {
    missing_file=()
    for file in $integrity_check_files; do
        if [ ! -f $file ]; then
            missing_file+=("${file}")
        fi
    done
    if check_net; then
        for file in ${missing_file[@]}; do
        echo -e "fetching missing file : $file"
            fetch_single_file ${file}
        done
    fi
}


#Backup Plan :)
# If any files missing then clone from git and build module ...
build () {
    ###############################################################################
    # if [ $? = 1 ]; then                                                         #
    #     [ -f $tmpdir ] && rm -rf $tmpdir                                        #
    #     echo -e "Cooking Module From Git Repo ...\n"                            #
    #     if check_net; then                                                      #
    #         # git clone $repo $tmpdir 2>&1 > /dev/null                          #
    #         cd $tmpdir                                                          #
    #         if [[ $arg == "-c" || $arg == "--clean" ]]; then                    #
    #             clean_build                                                     #
    #         fi                                                                  #
    #         if [[ $arg == "-d" || $arg == "--dirty" ]]; then                    #
    #             dirty_build                                                     #
    #         fi                                                                  #
    #         cd $tmpdir && zip -r9 $out_zip * 2>&1 > /dev/null                   #
    #         cd $here && [ -f $tmpdir/$out_zip ] && mv $tmpdir/$out_zip $here    #
    #         rm -rf $tmpdir                                                      #
    #     fi                                                                      #
    # else                                                                        #
    ###############################################################################

        [ -f $out_zip ] && rm -rf $out_zip
        if [[ $arg == "-c" || $arg == "--clean" ]]; then
            clean_build
        fi
        if [[ $arg == "-d" || $arg == "--dirty" ]]; then
            check_integrity
            dirty_build
        fi
        zip -r9 $out_zip $necessary_files 2>&1 > /dev/null
    ######
    # fi #
    ######


}

#where all goes started...
main () {
    local arg="$1"
    clear
    banner
    install_dep
    build 
    [ -f $out_zip ] && echo -e "Your Zip Here $here/$out_zip\n"


}

# Parse options
if [[ "$#" == 0 ]]; then
    show_help
else
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            -v|--version) show_ver; exit 0 ;;
            -d|--dirty|-c|--clean) main $1 | tee $log; exit 0 ;;
            *) show_help; shift ;;
        esac
    done
fi


