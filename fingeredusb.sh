#!/bin/bash
version=0.1
capturetime=10
verbose=0
log=0
param="$1"
check_params(){
#-------------------------------------------------------------------------------------
#	add code to allow user to specify how long to scan for
#-------------------------------------------------------------------------------------
	case $param in
		-v|--verbose)
		verbose=1
		;;
		-l|--log)
		log=1
		;;
		-vl|--verbose-log)
		verbose=1
		log=1
		;;
		-h|--help)
		help_prompt
		;;
		-t|--time)
		capturetime=2
		;;
		-*)
		input_error
		;;
	esac
}
kill_led(){
	dtparam=act_led_trigger=none
	dtparam=act_led_activelow=on
	printf "1" | sudo tee /sys/class/leds/led0/brightness
	printf "\r"
}
reset_led(){
	printf "0" | sudo tee /sys/class/leds/led0/brightness
	printf "\r"
	dtparam=act_led_trigger=mmc
	dtparam=act_led_activelow=off
}
check_modprobe(){
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Checking modprobe...                     " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Checking modprobe...                     "
		fi
	fi
	chk_mod="$(command -v modprobe)"
	if [ "${chk_mod}" ]
	then
		if [ "${verbose}" = 1 ]
		then
			if [ "${log}" = 1 ]
			then
				printf "Working\n" >> /home/pi/OS_Fingerprinter/log.txt
			else
				printf "Working\n"
			fi
		fi
	else
		if [ "${log}" = 1 ]
		then
			printf "modprobe not working\n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "modprobe not working\n"
		fi
		end_program
		exit
	fi
}
check_tcpdump(){
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Checking tcpdump...                      " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Checking tcpdump...                      "
		fi	
	fi
	chk_tcpd="$(command -v tcpdump)"
	if [ "${chk_tcpd}" ]
	then
		if [ "${verbose}" = 1 ]
		then
			if [ "${log}" = 1 ]
			then
				printf "Installed\n" >> /home/pi/OS_Fingerprinter/log.txt
			else
				printf "Installed\n"
			fi
		fi
	else
		if [ "${log}" = 1 ]
		then
			printf "Not installed.\n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Not installed.\n"
			read -p "Would you like to Install? [y/n] " yn
			case $yn in
				[Yy]* ) sudo apt-get install -y tcpdump; break;;
				[Nn]* ) end_program; exit;;
				* ) echo "Only yes or no.";;
			esac
		fi
	fi
}
capture_usb(){
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Turning on USB monitoring...             " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Turning on USB monitoring...             "
		fi
	fi
	sudo modprobe usbmon
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Done\nMounting devices...                      " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Done\nMounting devices...                      "
		fi
	fi
	sudo mount -t debugfs none_debugs /sys/kernel/debug &> /dev/null
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Done\nDevices found:                           " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Done\nDevices found:                           "
		fi
	fi
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			sudo ls /sys/kernel/debug/usb/usbmon | sed 's/.*\ //' | xargs -n1 | sort -u | xargs | sed 's/\>/,/g;s/,$//' >> /home/pi/OS_Fingerprinter/log.txt
		else
			sudo ls /sys/kernel/debug/usb/usbmon | sed 's/.*\ //' | xargs -n1 | sort -u | xargs | sed 's/\>/,/g;s/,$//'
		fi
	fi
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Detecting BUS...                         " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Detecting BUS...                         "
		fi
	fi
	busnumber="$(sudo lsusb -v | grep "Bus 0" | awk '{print $2;}' | sed 's/.*\0//' | xargs -n1 | sort -u | xargs | sed 's/\>/,/g;s/,$//')"
#-------------------------------------------------------------------------------------
#	add code to allow user to specify device to scan on:
#	echo The folloing USB devices were found on bus $busnumber:
#	sudo ls /sys/kernel/debug/usb/usbmon | grep "${busnumber}"
#-------------------------------------------------------------------------------------
	
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Done\n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Done\n"
		fi
	else
		if [ "${log}" = 1 ]
		then
			printf "\n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "\n"
		fi
	fi
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Buses found:                             \n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Buses found:                             \n"
		fi
	fi
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			lsusb >> /home/pi/OS_Fingerprinter/log.txt
			ls /dev/bus/usb/001 >> /home/pi/OS_Fingerprinter/log.txt
		else
			lsusb
			ls /dev/bus/usb/001
		fi
	fi
	
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "\n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "\n"
		fi
	fi
	if [ "${log}" = 1 ]
	then
		printf "Capturing USB packets on BUS number ${busnumber}..." >> /home/pi/OS_Fingerprinter/log.txt
	else
		printf "Capturing USB packets on BUS number ${busnumber}..."
	fi
	sudo cat /sys/kernel/debug/usb/usbmon/"${busnumber}"u > osfusbmon.txt &
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "\nCapturing for $capturetime second" >> /home/pi/OS_Fingerprinter/log.txt
			if [ "${capturetime}" != 1 ]
			then 
				printf "s..." >> /home/pi/OS_Fingerprinter/log.txt
			else
				printf "..." >> /home/pi/OS_Fingerprinter/log.txt
			fi
		else
			printf "\nCapturing for $capturetime second"
			if [ "${capturetime}" != 1 ]
			then 
				printf "s..."
			else
				printf "..."
			fi
		fi
	fi
	sleep $capturetime # time length of the scan
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "\nKilling capture service..." >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "\nKilling capture service..."
		fi
	fi
	sudo killall cat
	if [ "${log}" = 1 ]
	then
		printf "\n           USB Capture Finished          \n" >> /home/pi/OS_Fingerprinter/log.txt
	else
		printf "\n           USB Capture Finished          \n"
	fi
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "\n" >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "\n"
		fi
	fi
}
write_to_file(){
	if [ "${log}" = 0 ]
	then
		rm /home/pi/OS_Fingerprinter/log.txt
	fi
	if [ ! -d /home/pi/OS_Fingerprinter/scans/ ]
	then
		mkdir /home/pi/OS_Fingerprinter/scans
	fi
	if [ "${verbose}" = 1 ]
	then
		if [ "${log}" = 1 ]
		then
			printf "Detecting last file...                   " >> /home/pi/OS_Fingerprinter/log.txt
		else
			printf "Detecting last file...                   "
		fi
	fi
	i=0
	for (( i=1;i<101;i++ ))
	do
		if [ ! -f /home/pi/OS_Fingerprinter/scans/scan_$i.txt ]
		then
			if [ "${verbose}" = 1 ]
			then
				if [ "${log}" = 1 ]
				then
					printf "Done\nWriting results to scan_$i.txt...         " >> /home/pi/OS_Fingerprinter/log.txt
				else
					printf "Done\nWriting results to scan_$i.txt...         "
				fi
			fi
			cat osfusbmon.txt > /home/pi/OS_Fingerprinter/scans/scan_$i.txt
			if [ "${verbose}" = 1 ]
			then
				if [ "${log}" = 1 ]
				then
					printf "Done\n" >> /home/pi/OS_Fingerprinter/log.txt
				else
					printf "Done\n"
				fi
			fi
			break
		fi
	done
	rm osfusbmon.txt
}
input_error(){
	printf "[${param}] not allowed\n"
	init_prompt
	help_prompt
	exit
}
help_prompt(){
	printf "\n"
	printf "This tool was written and developed by Jacob Still\n"
	printf "FingeredUSB uses modprobe and tcpdump to predict an operating system via usb\n"
	printf "\nUsage: ./fingeredusb.sh [options]\n"
	printf "\nOptions:\n"
	printf "  -v            --verbose       verbose mode, shows more detail as to what is going on\n"
	printf "  -h            --help          help, display this screen\n"
	printf "  -t [seconds]  --time          amount of time in seconds to scan for\n"
	printf "\n(-t not currently working) - future update\n"
	exit
}
end_program(){
	#reset_led #i commented this out because it doesn't seem to work as of now
	if [ "${log}" = 1 ]
	then
		printf "Exitting...\n" >> /home/pi/OS_Fingerprinter/log.txt
		if [ ! -d /home/pi/OS_Fingerprinter/logs/ ]
		then
			mkdir /home/pi/OS_Fingerprinter/logs
		fi
		sudo mv /home/pi/OS_Fingerprinter/log.txt /home/pi/OS_Fingerprinter/logs/log_$i.txt
	else
		printf "Exitting...\n"
	fi
	exit
}
init_prompt(){
	printf "Operating System Fingerprinting via USB v$version\n" > /home/pi/OS_Fingerprinter/log.txt
	printf "Operating System Fingerprinting via USB v$version\n"
}
#	Main Program:
#kill_led #i commented this out because it doesn't seem to work as of now
init_prompt
check_params
check_modprobe
check_tcpdump
capture_usb
write_to_file
#-------------------------------------------------------------------------------------------------
#call python or something to sort through data gathered and determine os
#-------------------------------------------------------------------------------------------------
end_program
exit
