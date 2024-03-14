#!/bin/bash

scriptdir=$(cd $(dirname $0);pwd)
githubversion=$(./curl --silent "https://api.github.com/repos/lutris/lutris/releases/latest" | grep -Po "(?<=\"tag_name\": \").*(?=\")" | sed s/v//g)

if [ ! -e dwarfs-universal-0.7.3-Linux-x86_64 ]
   then

       wget https://github.com/mhx/dwarfs/releases/download/v0.7.3/dwarfs-universal-0.7.3-Linux-x86_64 && chmod a+x dwarfs-universal-0.7.3-Linux-x86_64
fi
if [ ! -e dwarfs/lutris ]
   then

       wget https://github.com/lutris/lutris/archive/refs/tags/v$githubversion.tar.gz
       tar -zxf v$githubversion.tar.gz
       mv lutris-$githubversion dwarfs/lutris
       rm v$githubversion.tar.gz
fi

./dwarfs-universal-0.7.3-Linux-x86_64 --tool=mkdwarfs -i dwarfs -o dwarfs.dwarfs
cat script.sh dwarfs-universal-0.7.3-Linux-x86_64 1 dwarfs.dwarfs > Lutris-Portable.sh && chmod a+x Lutris-Portable.sh
rm v$githubversion.tar.gz
