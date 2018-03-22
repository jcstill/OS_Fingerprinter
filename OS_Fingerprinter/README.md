This starts a capture service and then writes the data to a file

yes, i know, there are probably more effective ways of doing this,
but this is how i did it

BUGS: 

this script is started from `/etc/rc.local` through a launcher script (that waits for 30 sec for the boot process to finish). However, the results of the scan (in scan_#.txt while plugged into a computer is empty (maybe no data on port at time?)
