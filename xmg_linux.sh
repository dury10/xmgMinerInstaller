#!/bin/bash

#Made by dury10 Fork from Philipp "3D" ten Brink
#2018-01-06
#donations: XMG - 9KcKx8TdnNStNkp7qpjzJZ8CyDTs1RiGqF 

#GNU General Public License v3.0 see LICENSE

if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root or sudo."
	exit 1
fi

folder () { 

	if [ $1 -eq 0 ]; then 
		read -p "Input foldername where to create the files: " answer
	else
		answer="miner"
	fi
	
	mkdir $answer
	cd $answer

}

compileaarch64 () { 
	
	while true 
	do 
	
		if [ $1 -eq 0 ]; then 
			read -p "Download and compile newest miner version(takes longer)? Yes/No [yY/nN] " answer 
		else
			answer="y"
		fi

	  # (2) handle the input we were given 
	  case $answer in
	   [yY]* )  DEBIAN_FRONTEND=noninteractive apt-get -y -qq update > /dev/null 2>&1
				DEBIAN_FRONTEND=noninteractive apt-get -y -qq upgrade > /dev/null 2>&1
				DEBIAN_FRONTEND=noninteractive apt-get -y -qq install make git automake autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev zlib1g-dev > /dev/null 2>&1
				git clone https://github.com/magi-project/m-cpuminer-v2 > /dev/null 2>&1
				cd m-cpuminer-v2
				sudo ./autogen.sh > /dev/null 2>&1
				sudo CFLAG="-O2 mfpu=neon-vfpv4" ./configure > /dev/null 2>&1
				sudo make clean > /dev/null 2>&1 && sudo  make -j4 > /dev/null 2>&1
				echo "./m-cpuminer-v2"
		  break;;
		   
	   [nN]* )	
				read -p "Thanks, to exit the install pres Ctrl+C"
		  break;; 
		   
	  * )    echo "Yes/No [yY/nN]";;
		 
	  esac 
	done 

}

runme () { 

	while true 
	do 
	
		if [ $1 -eq 0 ]; then 
			read -p "Would you like to setup your mining pool RunMe? Yes/No [yY/nN] " answer 
		else
			answer="y"
		fi

	  # (2) handle the input we were given 
	  case $answer in
	   [yY]* )  
			cd m-cpuminer-v2
			poolcreds $2 > RunMe
			chmod +x RunMe
			echo "Finished installation. Use ./RunMe in your choosen directory /m-cpuminer-v2 to start mining."
		  break;;
		   
	   [nN]* )
		  break;; 
		   
	  * )   echo "Yes/No [yY/nN]";;
		 
	  esac 
	done 

}

poolcreds () { 
	
			read -p "poolurl: " poolurl
			read -p "poolport: " poolport
			read -p "username: " username
			read -p "workername: " workername
			read -p "workerpass: " workerpass
			read -p "threads: " threads
			read -p "cpu_efficiency: "  cpu_efficiency
			string="./m-minerd -a m7mhash -o stratum+tcp://$poolurl:$poolport -u $username.$workername -p $workerpass -t $threads -e $cpu_efficiency"
			echo $string
}

type=$(lscpu | grep -m 1 "Architecture:" | sed 's/[^=:]*[=:] //' | sed 's|[/ ]||g')

while true 
do 
  # (1) prompt user, and read command line argument 
  read -p "Use recommended settings? Yes/No [yY/nN] " answer 
 
  # (2) handle the input we were given 
  case $answer in 
   [yY]* )  default=1
	  break;;
	   
   [nN]* )
			default=0
	  break;; 
	   
  * )    echo "Yes/No [yY/nN]";;
	 
  esac 
done 

case $type in 
   x86_64) 
		folder $default
		gccinstall $default
		path=$(compilex86_64 $default)
		hugepages $default
		runme $default $path
		echo "1 If you like what I'm doing please donate :) XMG - 9KcKx8TdnNStNkp7qpjzJZ8CyDTs1RiGqF"
		exit 0;;
       
   armv71)
		folder $default
		path=$(compilearmv71 $default)
		runme $default $path
		echo "2 If you like what I'm doing please donate :) XMG - 9KcKx8TdnNStNkp7qpjzJZ8CyDTs1RiGqF"
		exit 0;;
	  
   aarch64)
		folder $default
		path=$(compileaarch64 $default)
		runme $default $path
		echo "3 If you like what I'm doing please donate :) XMG - 9KcKx8TdnNStNkp7qpjzJZ8CyDTs1RiGqF"
		exit 0;;
		
  * )   echo "Your CPU Architecture is not supported. Sorry"
		exit 1;;
     
esac 
