# P4wnP1_OS_Recognition
Groups tools used for OS detection into one easy to use package


basically build on the principles from P4wnP1's Ethernet over USB and usb connection to identify the Target Machine's Operating System.

P4wnP1's USB over Enternet is based on:
[-Poisontap-](https://github.com/samyk/poisontap/blob/master/pi_startup.sh)

Network scans:
[-Paper 1-](https://www.sans.org/reading-room/whitepapers/authentication/os-application-fingerprinting-techniques-32923)

USB scans:
[-Paper 1-](https://pdfs.semanticscholar.org/152d/ebadbbeb1322be2793f5257aabf8e3237356.pdf)
[-Paper 2-](https://cise.ufl.edu/~butler/pubs/ndss14.pdf)
[-Tool the papers used to analyse usb-](https://www.ellisys.com/products/usbex200/download.php)

Use wireshark or another tool to capture usb traffic
[-How to for my refrence-](https://technolinchpin.wordpress.com/2015/10/23/usb-bus-sniffers-for-linux-system/)
[-How to for my refrence-](https://stackoverflow.com/questions/31054437/how-to-install-wireshak-on-linux-and-capture-usb-traffic)


I will build a tool that does the above and analyses the results and makes a best guess as to what the os is. Based on [this](https://pdfs.semanticscholar.org/152d/ebadbbeb1322be2793f5257aabf8e3237356.pdf), it will probably rely heavily upon the USB detection
