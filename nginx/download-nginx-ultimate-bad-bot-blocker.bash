#!/bin/bash
### -----------------------------------------------------------
### THE NGINX ULTIMATE BAD BOT, BAD IP AND BAD REFERRER BLOCKER
### -----------------------------------------------------------

### VERSION INFORMATION #
###################################################
### Version: V4.2023.05.3757
### Updated: Fri May 19 22:01:08 UTC 2023
### Bad Referrer Count: 7104
### Bad Bot Count: 641
###################################################
### VERSION INFORMATION ##

### --------------------------------------------
### HELP SUPPORT THIS PROJECT - Send Me a Coffee
### https://ko-fi.com/mitchellkrog
### --------------------------------------------

##############################################################################                                                                
#       _  __     _                                                          #
#      / |/ /__ _(_)__ __ __                                                 #
#     /    / _ `/ / _ \\ \ /                                                 #
#    /_/|_/\_, /_/_//_/_\_\                                                  #
#       __/___/      __   ___       __     ___  __         __                #
#      / _ )___ ____/ /  / _ )___  / /_   / _ )/ /__  ____/ /_____ ____      #
#     / _  / _ `/ _  /  / _  / _ \/ __/  / _  / / _ \/ __/  '_/ -_) __/      #
#    /____/\_,_/\_,_/  /____/\___/\__/  /____/_/\___/\__/_/\_\\__/_/         #
#                                                                            #
##############################################################################                                                                

### This file implements a checklist / blacklist for good user agents, bad user agents and
### bad referrers on Nginx Web Server. It also has whitelisting for your own IP's and known good IP Ranges
### and also has rate limiting functionality for bad bots who you only want to rate limit
### and not actually block out entirely. It is very powerful and also very flexible.

### --------------------------------------------------------------------------
### Created By: https://github.com/mitchellkrogza/
### Repo Url: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
### Copyright Mitchell Krog - <mitchellkrog@gmail.com>
### Contributors: Stuart Cardall - https://github.com/itoffshore
### --------------------------------------------------------------------------

### --------------------------------------------------------------------------
### Tested on: nginx/1.10.3 up to latest Mainstream Version (Ubuntu 16.04)
### --------------------------------------------------------------------------

### This list was developed and is in use on a live Nginx server running some very busy web sites.
### It was built from the ground up using real data from daily logs and is updated almost daily.
### It has been extensively tested for false positives and all additions to the lists of bad user agents,
### spam referrers, rogue IP address, scanners, scrapers and domain hijacking sites are extensively checked
### before they are added. It is monitored extensively for any false positives.

### ---------
### Features:
### ---------
###	Clear formatting for Ease of Maintenance.
###	Alphabetically ordered lists for Ease of Maintenance.
###	Extensive Commenting for Ease of Reference.
###	Extensive bad_bot list
###	Extensive bad_referrer list (please excuse the nasty words and domains)
###	Simple regex patterns versus complicated messy regex patterns.
###	Checks regardless of http / https urls or the lack of any protocol sent.
###	IP range blocking / whitelisting.
###	Rate Limiting Functions.

### ------------
### INSTALLATION
### ------------

### PLEASE use the install, setup and update scripts provided for you to ease your installation.
### This Auto Installation procedure is documented in the README.md and AUTO-CONFIGURATION.md files.
### Installation, Setup and Update Scripts Contributed by Stuart Cardall - https://github.com/itoffshore
### There are also manual configuration instructions provided for those not wishing to do an auto install.

### -----------------------------------------------
###	!!!!! PLEASE READ INLINE NOTES ON TESTING !!!!!
### -----------------------------------------------

###	SETTINGS: 
### ---------------------------------------------
###	0 = allowed - no limits
###	1 = allowed or rate limited less restrictive
###	2 = rate limited more
###	3 = block completely
### ---------------------------------------------

### ------------------------------------------------------------
### CONTRIBUTING / PULL REQUESTS / ADDING YOUR OWN BAD REFERRERS
### ------------------------------------------------------------

### For contributing, corrections or adding bots or referrers to this repo,
### Send a Pull Request (PR) on any of the .list files in the _generator_lists folder
### All Pull Requests will be checked for accuracy before being merged.

# -----------------------
# !!!!! PLEASE TEST !!!!!
# -----------------------

# ALWAYS test any User-Agent Strings you add here to make sure you have it right
# Use a Chrome Extension called "User-Agent Switcher for Chrome" where you can create your
# own custom lists of User-Agents and test them easily against your rules below.

# You can also use curl from the command line to test user-agents as per the examples below:

# curl -I http://www.yourdomain.com -A "GoogleBot"  ---- GIVES YOU: HTTP/1.1 200 OK (Meaning web page was served to Client)
# curl -I http://www.yourdomain.com -A "80legs"     ---- GIVES YOU: curl: (52) Empty reply from server (Meaning Nginx gave a 444 Dropped Connection)

longest_str() {
	echo $@ | tr " " "\n" | awk '{print length ($0)}' | sort -nr | head -n1
}

download_files() {
	local url= x= local_file= remote_path= remote_dir=$1 local_dir=$2 tmp= retval=
	local file_list="$(echo $@ | awk '{$1=$2=""; print $0}' | sed -e 's/^[ \t]*//')" # rm leading whitespace
	local col_size=$(( $(longest_str $file_list) + $(echo $remote_dir | wc -m) ))

    printf "\nREPO = $REPO\n\n"

    for x in $file_list; do
        local_file=$local_dir/$x

        if [ "$remote_dir" = "/" ]; then
            remote_path=$x
        else
            remote_path="$remote_dir/$x"
        fi

        printf "%-21s %-$(( $col_size +8 ))s %s" \
        "Downloading [FROM]=>" \
        "[REPO]/$remote_path" \
        "[TO]=>  $local_file"

        tmp=$(mktemp)
        url=$REPO/$remote_path
        curl --fail --connect-timeout 60 --retry 10 --retry-delay 5 -so $tmp $url
        retval=$?

        case "$retval" in
                0) printf "...OK\n"
                mv $tmp $local_file
                ;;
            22) printf "...ERROR 404: $url\n";;
            28) printf "...ERROR TIMEOUT: $url\n";;
             *) printf "...ERROR CURL: ($retval)\n";;
        esac

        sed -i -E "s/\/etc\/nginx\/conf\.d/\/etc\/nginx\/snippets/i" $local_file
        sed -i -E "s/\/etc\/nginx\/bots\.d/\/etc\/nginx\/snippets/i" $local_file
        sed -i -E "s/\/etc\/nginx\/deny\.d/\/etc\/nginx\/snippets/i" $local_file
    done
}



REPO=https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master

include_filename=include_filelist.txt
include_url=$REPO/$include_filename

if [ -f $include_filename ]; then
    rm $include_filename
fi

CONF_FILES="
	globalblacklist.conf
	botblocker-nginx-settings.conf
	"

BOT_FILES="
	blockbots.conf
	ddos.conf
	custom-bad-referrers.conf
	bad-referrer-words.conf
	blacklist-ips.conf
	blacklist-user-agents.conf
	whitelist-domains.conf
	whitelist-ips.conf
	"


wget -q $include_url -O include_filelist.txt

source $include_filename


download_files conf.d config/snippets $CONF_FILES
download_files bots.d config/snippets $BOT_FILES
download_files deny.d config/snippets deny.conf


