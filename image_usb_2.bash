#!/bin/bash
# image a usb drive

function USAGE {
	echo
	echo "USAGE: "
	echo "$0 [option] -f [file] -c [CONFNAME]"
	echo "-w write image to drive"
	echo "-t test "
	echo "-f [file] where [file] is the disk image"
	echo "-c [CONFNAME] where [CONFNAME] is the disk label, e.g. \"HOTOS '11\""
	echo
}

function FINDDISKS {
	   for TARGETDISK in `mount | grep msdos | awk '{print $1}' | sed 's/\/dev\///g' | sort | uniq`
	   do
			 if [ -b /dev/$TARGETDISK ] && [ $TESTIT = "T" ]
			 then
				    PROCESS_T

			 elif [ -b /dev/$TARGETDISK ] && [ $TESTIT = "F" ]
			 then
				    PROCESS

			 else
				echo "$TARGETDISK isn't a Disk"
			 fi
	   done
}

function EJECT {
	   for TARGETDISK in `mount | grep msdos | awk '{print $1}' | sed 's/\/dev\///g' | sort | uniq`
	   do
			 TARGETDRIVE="`echo $TARGETDISK | sed 's/\s1//g'`"
			 if [ -b /dev/$TARGETDISK ] && [ $TESTIT = "T" ]
			 then
				    echo "diskutil eject \"$TARGETDRIVE\""
			 elif [ -b /dev/$TARGETDISK ] && [ $TESTIT = "F" ]
			 then
				    diskutil eject $TARGETDRIVE
			 else
				    echo "$TARGETDISK couldn't be ejected"
			 fi
	   done
}


function TEST {
	FINDDISKS
}
function WRITE {
	FINDDISKS
}

function PROCESS_T {
		TARGETDRIVE="`echo $TARGETDISK | sed 's/\s1//g'`"
		echo "diskutil partitionDisk \"$TARGETDRIVE\" MBRFormat \"MS-DOS FAT32\" \"$CONFNAME\" 100%"
		if [ $? -eq 0 ]
		then
			   echo "asr imagescan --filechecksum --source \"$SOURCEIMG\""
			   echo "asr restore -noverify -erase -noprompt -source \"$SOURCEIMG\" -t \"/dev/$TARGETDISK\""
			   echo "--------- $TARGETDRIVE written -------------" 
		else
			echo "$TARGETDRIVE FAILED partitioning"
		fi
}

function PROCESS {
		TARGETDRIVE="`echo $TARGETDISK | sed 's/\s1//g'`"
		diskutil partitionDisk $TARGETDRIVE MBRFormat "MS-DOS FAT32" "$CONFNAME" 100%
		if [ $? -eq 0 ]
		then
			   asr  imagescan --filechecksum --source "$SOURCEIMG"
			   asr restore -noverify -erase -noprompt -source "$SOURCEIMG" -t "/dev/$TARGETDISK"
			   echo "--------- $TARGETDRIVE written -------------" 
		else
			echo "$TARGETDRIVE FAILED partitioning"
		fi
}


if [ $1 ]
then
	while getopts "wtf:c:" Option
	do
		case $Option in
			w )  TESTIT="F";;

			t )  TESTIT="T";;

			f )	SOURCEIMG="$OPTARG" ;;

			c )	CONFNAME="$OPTARG" ;;

			* )  USAGE;;
		esac
	done
	
	

	   if [ -f $SOURCEIMG ] && [ "$CONFNAME" ] && [ $TESTIT = "T" ]
	   then
			 TEST
			 EJECT
	   elif [ -f $SOURCEIMG ] && [ "$CONFNAME" ] && [ $TESTIT = "F" ]
	   then
			 WRITE
			 EJECT
	   else
	   		echo "Main1"
	   		USAGE
	   fi
else
	echo "MAIN2"
	USAGE
fi
