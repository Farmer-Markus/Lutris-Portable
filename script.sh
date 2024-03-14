#!/bin/bash

#Sets variables and functions#
##############################
scriptdir=$(cd $(dirname $0);pwd)
scriptname=$(basename "$0")
offset=auto
mountpoint="/tmp"
workdir=$scriptdir
Begin_dwarfs_universal=`awk '/^#__Begin_dwarfs_universal__/ {print NR + 1; exit 0; }' "$scriptdir/$scriptname"`
End_dwarfs_universal=`awk '/^#__End_dwarfs_universal__/ {print NR - 1; exit 0; }' "$scriptdir/$scriptname"`
if [ -e "/dev/shm" ]; then mountpoint="/dev/shm"; fi

sh_mount () {
  if [[ ! "$usrmntpnt" == "1" && -e "/dev/shm" ]]; then mountpoint="/dev/shm"; fi
  if [ ! -e "$mountpoint/Lutris-Portable" ]
     then

         mkdir -p "$mountpoint/Lutris-Portable/mount-tools"
         mkdir -p "$mountpoint/Lutris-Portable/mnt"
         awk "NR==$Begin_dwarfs_universal, NR==$End_dwarfs_universal" "$scriptdir/$scriptname" > "$mountpoint/Lutris-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64" && chmod a+x "$mountpoint/Lutris-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64"
         "$mountpoint/Lutris-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64" --tool=dwarfs "$scriptdir/$scriptname" "$mountpoint/Lutris-Portable/mnt" -o offset=$offset
         ln -s "$scriptdir/.." "$mountpoint/Lutris-Portable/scriptlocation"
fi
}

sh_unmount () {
  umount "$mountpoint/Lutris-Portable/mnt"
  rm -r "$mountpoint/Lutris-Portable"
}

sh_help () {
  export LD_LIBRARY_PATH="$mountpoint/Lutris-Portable/mnt/libs/"
  echo 'sh Options'
  echo '----------'
  echo '--mount                     Mounts the dwarfs filesystem in '$mountpoint''
  echo '                            (can be used with <--mountpoint>)'
  echo ''
  echo '--mountpoint=<path>         Defines the mount location for the dwarfs'
  echo '                            image.(Default mountpoint: </dev/shm or /tmp>)'
  echo ''
  echo '-------------------------------------------------------------------------'
  "$mountpoint/Lutris-Portable/mnt/python3.10/bin/python3.10" "$mountpoint/Lutris-Portable/mnt/lutris/bin/lutris" --help
  umount "$mountpoint/Lutris-Portable/mnt"
  rm -r "$mountpoint/Lutris-Portable"
  exit
}

sh_if_mounted () {
  if [[ ! "$usrmntpnt" == "1" && -e "/dev/shm" ]]; then mountpoint="/dev/shm"; fi
  if [ ! -e "$mountpoint/Lutris-Portable" ]
     then

         sh_mount
         echo -e "\033[1;32mImage mounted in $mountpoint\033[0;38m"
         exit

     else

         umount "$mountpoint/Lutris-Portable/mnt"
         rm -r "$mountpoint/Lutris-Portable"
         echo -e "\033[1;31mImage unmounted\033[0;38m"
         exit
fi
}

sh_install () {
  if [ -e ~/.local/share/Lutris-Portable ]
     then

	 echo -e "\033[1;31mFolder Lutris-Portable already exists in ~/.local/share\033[0;38m"
	 if [ ! -e ~/.local/share/applications/lutris-portable.desktop ]; then sh_create_entry && echo -e "\033[1;32mFixed missing desktop entry\033[0;38m"; fi
	 echo -e "\033[1;31mCan't install in ~/.local/share\033[0;38m"
	 echo -e "\033[1;31mAlready installed\033[0;38m"
	 echo -e "\033[1;31mWould you like to uninstall? All data will be removed![Y/n]\033[0;38m"
	 read input
	 case $input in
	     y|yes)
	     sh_uninstall
	     ;;
	     n|no)
	     echo -e "\033[1;31mAborting\033[0;38m"
	     ;;
	     *)
	     echo -e "\033[1;31mAborting\033[0;38m"
	     ;;
	 esac
	 exit

     else

	 echo -e "\033[1;32mInstalling Lutris in ~/.local/share...\033[0;38m"
	 sh_mount
	 mkdir -p ~/.local/share/Lutris-Portable
	 cp "$scriptdir/$scriptname" ~/.local/share/Lutris-Portable
	 cp "$mountpoint/Lutris-Portable/mnt/install/Lutris.png" ~/.local/share/Lutris-Portable/
	 if [ -e ~/.local/share/applications/lutris-portable.desktop ]; then rm ~/.local/share/applications/lutris-portable.desktop; fi
	 echo -e "\033[1;32mCreating desktop entry...\033[0;38m"
	 sh_create_entry
	 echo -e "\033[1;32mDone\033[0;38m"
	 sh_unmount
	 echo -e "\033[1;32mFinished installing Lutris in ~/.local/share.\033[0;38m"
fi
}

sh_create_entry () {
  echo '[Desktop Entry]'								>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Name=Lutris'									>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Exec='$HOME'/.local/share/Lutris-Portable/Lutris-Portable.sh'			>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Type=Application'								>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Keywords=game;wine;windows;'							>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Categories=Games;'								>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Comment=A portable version of Lutris that helps you install and play video games from all eras and from most gaming systems.'										>> ~/.local/share/applications/lutris-portable.desktop
  echo 'StartupNotify=true'								>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Terminal=false'									>> ~/.local/share/applications/lutris-portable.desktop
  echo 'Icon='$HOME'/.local/share/Lutris-Portable/Lutris.png'				>> ~/.local/share/applications/lutris-portable.desktop
}

sh_uninstall () {
  echo -e "\033[1;32mUninstalling Lutris in ~/.local/share...\033[0;38m"
  echo -e "\033[1;31mAll data will be removed in\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m3		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m2		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m1		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  
  echo -e "\033[1;32mRemoving data...\033[0;38m"
  rm -rf ~/.local/share/Lutris-Portable
  echo -e "\033[1;32mRemoving desktop entry...\033[0;38m"
  rm ~/.local/share/applications/lutris-portable.desktop
  echo -e "\033[1;32mFully uninstalled Lutris in ~/.local/share\033[0;38m"
}

sh_lutris () {
  export LD_LIBRARY_PATH="$mountpoint/Lutris-Portable/mnt/libs/:$PATH"
  export HOME="$workdir"
  "$mountpoint/Lutris-Portable/mnt/python3.10/bin/python3.10" "$mountpoint/Lutris-Portable/mnt/lutris/bin/lutris" $lutrisargs
}
#Scriptstart#
#############
for i in "$@"
do
case $i in
    "-?"|-h|--h|--help)
    help=1
    ;;
    --mount)
    mount=1
    ;;
    --mountpoint=*)
    usrmntpnt=1 && mountpoint="${i#*=}"
    ;;
    --install)
    install=1
    ;;
    *)
    lutrisargs="$lutrisargs $i"
    ;;
esac
done

if [ "$install" == "1" ]; then sh_install && exit; fi
if [ "$help" == "1" ]; then sh_mount && sh_help; fi
if [ "$mount" == "1" ]; then sh_if_mounted; else sh_mount && sh_lutris && sh_unmount ; fi


exit
#__Begin_dwarfs_universal__
