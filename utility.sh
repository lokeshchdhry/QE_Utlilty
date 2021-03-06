#!/bin/bash
username="----- Username -------"
password="----- Password -------" 

bold=$(tput bold)
normal=$(tput sgr0)

check_env(){
	a="appc -v -o json"
	b="appc ti -v"
	c="appc alloy -v"
	d="appc ti sdk"
	e="grep -n -i "VERSION" version.txt"
	f="sw_vers -productVersion"
	g="/usr/bin/xcodebuild -version"
	h="node -v"
	i="appc whoami"
	j="java -version"

	echo
	echo ${bold}MAC VERSION:${normal}
	echo ------------
	$f

	echo
	echo ${bold}XCODE VERSION:${normal}
	echo -------------
	$g

	echo
	echo ${bold}JAVA VERSION:${normal}
	echo -------------
	$j

	echo
	echo ${bold}APPC CLI AND APPC NPM VERSION:${normal}
	echo -----------------------------
	$a
	echo

	echo ${bold}APPC TI CLI VERSION:${normal}
	echo -------------------
	$b
	echo

	echo ${bold}APPC ALLOY VERSION:${normal}
	echo ------------------
	$c
	echo

	echo ${bold}NODE VERSION:${normal}
	echo -------------
	$h
	echo

	#echo ${bold}HIGHEST AND THE SELECTED SDK VERSION:${normal}
	echo ${bold}SELECTED SDK VERSION:${normal}
	echo ---------------------
	#echo -------------------------------------
	x=($($d))
	#echo "Highest :"${x[23]}
	echo "Selected :"$($d|grep -i 'selected'| cut -c4-25)
	echo

    echo ${bold}ANDROID MODULES INSTALLED:${normal}
    echo --------------------------
    check_android_module_ver
    echo

    echo ${bold}IOS MODULES INSTALLED:${normal}
    echo ----------------------
    check_ios_module_ver
    echo

    echo ${bold}PLUGINS INSTALLED:${normal}
    echo ----------------------
    check_hyperloop_plugin_ver
    echo

	echo ${bold}STUDIO VERSION:${normal}
	echo        ---------------
	cd "/Applications/Appcelerator Studio/"
	$e|awk -F "VERSION" '{print $2}'|cut -c2-19
	echo

	echo ${bold}ENVIRONMENT:${normal}
	echo        ------------
	$i|grep "$username"|grep "organization"|cut -c6-
	echo
}

check_android_module_ver(){
	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/android/ti.map/
	map_ver=$(ls -dm *)
	echo Android Map Module Versions Installed: $map_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/android/ti.cloudpush
	cloudpush_ver=$(ls -dm *)
	echo CloudPush Versions Installed: $cloudpush_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/android/facebook
	facebook_ver=$(ls -dm *)
	echo Android FaceBook Modules Installed: $facebook_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/commonjs/ti.cloud
	cloud_ver=$(ls -dm *)
	echo Ti.Cloud Versions Installed: $cloud_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/android/hyperloop
	hyperloop_ver=$(ls -dm *)
	echo Hyperloop Versions Installed: $hyperloop_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/android/com.appcelerator.aca
	aca_ver=$(ls -dm *)
	echo ACA Versions Installed: $aca_ver
	cd ~/Desktop
}

check_ios_module_ver(){
	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/iphone/ti.map
	ios_map_ver=$(ls -dm *)
	echo IOS Map Modules Installed: $ios_map_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/iphone/facebook
	ios_fb_mod_ver=$(ls -dm *)
	echo IOS Facebook Modules Installed: $ios_fb_mod_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/iphone/ti.coremotion
	ios_coremotion_mod_ver=$(ls -dm *)
	echo IOS Coremotion Modules Installed: $ios_coremotion_mod_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/iphone/hyperloop
	hyperloop_ver=$(ls -dm *)
	echo Hyperloop Versions Installed: $hyperloop_ver

	cd /Users/lchoudhary/Library/Application\ Support/Titanium/modules/iphone/com.appcelerator.aca
	aca_ver=$(ls -dm *)
	echo ACA Versions Installed: $aca_ver
	cd ~/Desktop
}

check_hyperloop_plugin_ver(){
	cd /Users/lchoudhary/Library/Application\ Support/Titanium/plugins/hyperloop
	hyperloop_plugin_ver=$(ls -dm *)
	echo Hyperloop Plugin Installed: $hyperloop_plugin_ver
}

to_prod(){
	echo
	echo ${bold}SETTING THE APPC CLI ENVIRONMENT TO PRODUCTION:${normal}
	echo -----------------------------------------------
	appc logout
	appc config set defaultEnvironment production
	APPC_ENV=production
	echo -ne '\n' |appc login --username $username --password $password
	echo
}

to_preprod(){
	echo
	echo ${bold}SETTING THE APPC CLI ENVIRONMENT TO PRE-PRODUCTION:${normal}
	echo ---------------------------------------------------
	appc logout
	appc config set defaultEnvironment preproduction
	APPC_ENV=preproduction
	echo -ne '\n' |appc login --username $username --password $password
}

install_core(){
	echo
	echo ${bold}INSTALLING APPC CORE:${normal}
	echo ---------------------
	echo -n "Enter the appc core version to install :"
	read core
	appc use $core
	echo
	echo DONE
}

install_GA_core(){
	arg1=$1
	echo
	echo ${bold}INSTALLING GA APPC CORE:${normal}
	echo ------------------------
	appc use $arg1
	echo
	echo DONE
}

install_appc_npm(){
	echo
	echo ${bold}INSTALLING APPC NPM:${normal}
	echo --------------------
	echo -n "Enter the appc NPM version to install :"
	read appcnpm
	sudo npm install -g appcelerator@$appcnpm
	echo
	echo DONE
}

install_GA_appc_npm(){
	arg1=$1
	echo
	echo ${bold}INSTALLING GA APPC NPM:${normal}
	echo -----------------------
	sudo npm install -g appcelerator@$arg1
	# echo
	# echo "Installed GA Appc NPM & SDK :" $(appc -v -o json)
	echo
	echo DONE
}

install_sdk(){
	en1=$(appc whoami| grep -o 'preprod')
	en2=$(appc whoami|grep -o 'prod')
	if [ "$en1" == "preprod" ]; then
			echo
			echo "||=======================================================================||"
			echo "||  YOU ARE IN PREPROD GOING TO PROD TO USE APPC COMMAND TO GET THE SDK  ||"
			echo "||=======================================================================||"
			to_prod
			echo ${bold}INSTALLING SDK AND SETTING AS DEFAULT:${normal}
			echo --------------------------------------
			echo -n "Enter the branch to install sdk from :"
			read branch
			appc ti sdk install -b $branch --default
			echo
			echo DONE
			echo
			echo "||==============================================||"
			echo "||           GOING BACK TO PREPROD              ||"
			echo "||==============================================||"
			to_preprod
			echo
			echo DONE
	else
		if [ "$en2" == "prod" ]; then
				echo
				echo "||==========================================================||"
				echo "||  YOU ARE IN PROD, I CAN USE APPC COMMAND TO GET THE SDK  ||"
				echo "||==========================================================||"
				echo
				echo ${bold}INSTALLING SDK AND SETTING AS DEFAULT:${normal}
				echo --------------------------------------
				echo -n "Enter the branch to install sdk from :"
				read branch
				appc ti sdk install -b $branch --default
				echo
				echo DONE
		fi
	fi
}

install_specific_sdk(){
	en1=$(appc whoami| grep -o 'preprod')
	en2=$(appc whoami|grep -o 'prod')
	if [ "$en1" == "preprod" ]; then
			echo
			echo "||=======================================================================||"
			echo "||  YOU ARE IN PREPROD GOING TO PROD TO USE APPC COMMAND TO GET THE SDK  ||"
			echo "||=======================================================================||"
			to_prod
			echo ${bold}INSTALLING SDK AND SETTING AS DEFAULT:${normal}
			echo --------------------------------------
			echo -n "Enter the sdk version to install :"
			read sdk_ver
			appc ti sdk install $sdk_ver --default
			echo
			echo DONE
			echo
			echo "||==============================================||"
			echo "||           GOING BACK TO PREPROD              ||"
			echo "||==============================================||"
			to_preprod
			echo
			echo DONE
	else
		if [ "$en2" == "prod" ]; then
				echo
				echo "||==========================================================||"
				echo "||  YOU ARE IN PROD, I CAN USE APPC COMMAND TO GET THE SDK  ||"
				echo "||==========================================================||"
				echo
				echo ${bold}INSTALLING SDK AND SETTING AS DEFAULT:${normal}
				echo --------------------------------------
				echo -n "Enter the sdk version to install :"
				read $sdk_ver
				appc ti sdk install $sdk_ver --default
				echo
				echo DONE
		fi
	fi
}

install_GA_sdk(){
	arg1=$1
	en1=$(appc whoami| grep -o 'preprod')
	en2=$(appc whoami|grep -o 'prod')
	if [ "$en1" == "preprod" ]; then
			echo
			echo "||=======================================================================||"
			echo "||  YOU ARE IN PREPROD GOING TO PROD TO USE APPC COMMAND TO GET THE SDK  ||"
			echo "||=======================================================================||"
			to_prod
			echo ${bold}INSTALLING SDK AND SETTING AS DEFAULT:${normal}
			echo --------------------------------------
			appc ti sdk install $arg1
			echo
			echo "Setting SDK $arg1 as default. Please wait ....."
			echo
			appc ti sdk select $arg1
			echo
			echo DONE
			echo
			echo "||==============================================||"
			echo "||           GOING BACK TO PREPROD              ||"
			echo "||==============================================||"
			to_preprod
			echo
			echo DONE
	else
		if [ "$en2" == "prod" ]; then
				echo
				echo "||==========================================================||"
				echo "||  YOU ARE IN PROD, I CAN USE APPC COMMAND TO GET THE SDK  ||"
				echo "||==========================================================||"
				echo
				echo ${bold}INSTALLING SDK AND SETTING AS DEFAULT:${normal}
				echo --------------------------------------
				appc ti sdk install $arg1 -d
				echo
				echo DONE
		fi
	fi
}

install_GA_compo(){
	echo
	echo -n "Enter the GA release version for which you want to install the componemts(e.g 5.3.0): "
	read GA_version
	GA_url="https://raw.githubusercontent.com/lokeshchdhry/GA_Versions/master/$GA_version.GA_components.txt"
	check_exists=$(curl -s https://raw.githubusercontent.com/lokeshchdhry/GA_Versions/master/$GA_version.GA_components.txt|grep "404"|cut -c1-3)
	if [ "$check_exists" != "404" ]; then
		echo
		sdk_var=$(curl -s $GA_url |awk -F "Appc_sdk=" '{print $2}')
		npm_var=$(curl -s -L $GA_url |awk -F "Appc_npm=" '{print $2}')
		core_var=$(curl -s -L $GA_url |awk -F "Appc_core=" '{print $2}')

		echo ${bold}$GA_version.GA Components:${normal}
		echo ----------------------
		echo SDK: $sdk_var
		echo Appc NPM: $npm_var
		echo Appc Core: $core_var

		install_GA_sdk $sdk_var
		install_GA_appc_npm $npm_var
		install_GA_core $core_var
	else
		echo
		echo "GA components for $GA_version not found. Please enter release version 5.1.0 & above."
	fi
}

select_specific_sdk(){
	echo
	echo ${bold}SELECTING SPECIFIC SDK:${normal}
	echo -------------------------------
	echo -n "Enter the SDK version to select :"
	read sdk
	appc ti sdk select $sdk
	echo
	echo DONE
}

get_current_env(){
	a="appc -v -o json"
	b="appc ti -v"
	c="appc alloy -v"
	d="appc ti sdk"
	f="sw_vers -productVersion"
	g="/usr/bin/xcodebuild -version"
	h="node -v"
	i="appc whoami"
	j="javac -version"

	k="$(adb devices|awk -F 'device' '{print $1}'|sed '1d'|tr -d '\n'|tr '[[:blank:]]/' ','|awk -v b=1 -F ',' '{print $b}')"
	if [ "$k" != "" ]; then
		device="$(adb -s $k shell getprop ro.product.model)"
		device_os=" running $(adb -s $k shell getprop ro.build.version.release)"
		device_os+=$device
	else
		device_os="No device attached"
	fi

	echo "----------------------------------------------------------"
	
	echo

	std=$(grep -n -i "VERSION" /Applications/"Appcelerator Studio"/version.txt|awk -F "VERSION" '{print $2}'|cut -c2-19)
	echo Appc Studio : $std

	echo SDK Version : $($d|grep -i 'selected'| cut -c4-25)

	echo Mac OS Version : $($f)

	echo Xcode Version : $($g)
	
	echo Appc CLI AND Appc NPM : $($a)

	echo Ti CLI : $($b)

	echo Alloy : $($c)

	echo Node : $($h)

	echo Device: $device_os

	echo Environment: $($i|grep "$username"|grep "organization"|cut -c50-)

	echo

	echo "----------------------------------------------------------"
}

quit(){
	echo
	for pid in `ps -ef | grep utility.sh | awk '{print $3}'` ;
		do
			kill $pid ;
		done
}

# remove_node(){
# 	echo
# 	echo "Removing node files from :/usr/local/lib :"
# 	cd /usr/local/lib
# 	sudo rm -rf node*
# 	echo "Removinf node files from :/usr/local/include :"
# 	cd /usr/local/include
# 	sudo rm -rf node*
# 	echo "removing node executables from: /usr/local/bin :"
# 	cd /usr/local/bin
# 	sudo rm -rf /usr/local/bin/npm
# 	echo "Running "node -v" to check if node uninstalled :"
# 	echo
# 	echo DONE
# }


logs="
CHANGELOGS:
\n-----------
\nVer.0.1: --> Initial script.\n
\nVer.0.2: --> Added functionality, if in preprod, to go to prod & use appc command to get the sdk and come back to preprod. If in prod then stay in prod & get the sdk. Thanks Wilson for this suggestion :)
\n         --> Added changelogs
\n 		   --> Changes in menu UI.\n
\nVer.0.3: --> Added functionality to install all current GA components.
\n 		   --> UI improvements.\n
\nVer.0.4: -->Added functionality to remove node from system.\n
\nVer.0.5: -->Removed functionality to remove node as it did not work as expected.
\n         -->Added functionality to get the versions of Ti.map, facebook, Ti.cloudpush & Ti.cloud modules.\n
\nVer.0.6: -->Added functionality to installed module versions fopr IOS.\n
\nVer.0.6.2-->Added functionality to check for Java version & hyperloop module ver, hyperloop plugin.\n
\nVer.0.6.3-->Added functionality to select specific SDK.\n
\nVer.0.6.4-->Added functionality to get components to paste in JIRA tickets.
"

# set an infinite loop
while :
do
        # display menu
    echo
    echo "QE UTILITY Ver:0.6.4"
	echo "||===============================||"
	echo "||    WHAT DO YOU WANT TO DO     ||"
	echo "||===============================||"
	echo "1. CHECK INSTALLED COMPONENTS."
	echo "2. INSTALL APPC CORE."
	echo "3. INSTALL APPC NPM."
	echo "4. INSTALL TITANIUM SDK."
	echo "5. INSTALL SPECIFIC TITANIUM SDK."
	echo "6. SELECT SPECIFIC TITANIUM SDK."
	echo "7. INSTALL ALL(Core, Appc NPM, SDK)."
	echo "8. INSTALL ALL CURRENT GA COMPONENTS."
	echo "9. CHANGE ENV TO PRODUCTION."
	echo "10.CHANGE ENV TO PRE-PRODUCTION."
	echo "11.GET CURRENT ENVIRONMENT FOR COPYING TO JIRA TICKETS."
	echo "12.VIEW CHANGELOGS."
	echo "13.Exit."
	echo
        # get input from the user
	read -p "Enter your choice :" choice
        # make decision using case..in..esac
	case $choice in
		1)
			#Check Installed Components
			check_env
			;;
		2)
			#Install Core
			install_core
			;;
		3)
			#Install Appc NPM
			install_appc_npm
			;;
		4)
			#Install SDK
			install_sdk
			;;
		5)
			#Install SDK
			install_specific_sdk
			;;
		6)
			#Install SDK
			select_specific_sdk
			;;
		7)
			#Install All
			install_core
			install_appc_npm
			install_sdk
			;;
		8)
			#Install all current GA components
			install_GA_compo
			;;
		9)
			#Change to production
			to_prod
			;;
		10)
			#Change to pre-production
			to_preprod
			;;
		11)
			#Get current environment for jira tickets
			get_current_env
			;;

		12)
			#View Changelogs
			echo
			echo -e$logs
			;;
		13)
			#Quit
			echo "Bye!"
			quit
			;;
		*)
			#Invalid Option
			echo "Error: Invalid option..."
			echo
			;;
	esac
done
