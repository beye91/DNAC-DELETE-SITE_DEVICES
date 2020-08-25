#!/bin/bash

# Setting variables
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;36m"
NORM="\033[0m"

timestamp=`date +%Y%m%d-%H-%M-%S`
mkdir -p /tmp/dnac_device_site-deletion_logs/${timestamp}
tmp_dir="/tmp/dnac_device_site-deletion_logs/${timestamp}"

function help
{
  echo "Usage: delete_devices-sites.sh [-d] [-h]"
  echo ""
  echo "   -d  DNA-Center IP address"
  echo "   -h  Help menue"
  echo ""
  echo ""
}

function header
{
  printf "\n"
  printf "\n"
  printf "${BLUE}                                                                                                      ${NORM}\n"
  printf "${BLUE}                         000                                             000                          ${NORM}\n"
  printf "${BLUE}                        00000                                           00000                         ${NORM}\n"
  printf "${BLUE}                        00000                                           00000                         ${NORM}\n"
  printf "${BLUE}                        00000                                           00000                         ${NORM}\n"
  printf "${BLUE}              00        00000        000                     000        00000         00              ${NORM}\n"
  printf "${BLUE}             0000       00000       00000                   00000       00000        0000             ${NORM}\n"
  printf "${BLUE}             0000       00008       00000                   00000       00000        0000             ${NORM}\n"
  printf "${BLUE}             0000       00000       00000         0         00000       00000        0000         00  ${NORM}\n"
  printf "${BLUE} 0000        0000       00000       00000        000        00000       00000        0000        0000 ${NORM}\n"
  printf "${BLUE} 0000        0000       00000       00000       00000       00000       00000        0000        0000 ${NORM}\n"
  printf "${BLUE} 0000        0000       00000       00000       00000       00000       00000        0000        0000 ${NORM}\n"
  printf "${BLUE} 0000        0000       00000       00000       00000       00000       00000        0000        0000 ${NORM}\n"
  printf "${BLUE} 0000        0007       00000        000         000         000        00000         00          00  ${NORM}\n"
  printf "${BLUE}                        00000                                           00000                         ${NORM}\n"
  printf "${BLUE}                        00000                                           00000                         ${NORM}\n"
  printf "${BLUE}                         000                                             000                          ${NORM}\n"
  printf "\n"
  printf "\n"
  printf "${RED}               000000000      0000        000000000         000000000         0000000000               ${NORM}\n"
  printf "${RED}             00000000000      0000       0000000000       000000000000      00000000000000             ${NORM}\n"
  printf "${RED}            000000000000      0000      00000            0000000000000     00000000 0000000            ${NORM}\n"
  printf "${RED}           00000              0000      00000           000000            000000       00000           ${NORM}\n"
  printf "${RED}           00000              0000       000000000      00000             00000        00000           ${NORM}\n"
  printf "${RED}           00000              0000        000000000     00000             00000        00000           ${NORM}\n"
  printf "${RED}           00000              0000             00000    000000            00000        00000           ${NORM}\n"
  printf "${RED}            000000000000      0000             00000     0000000000000      0000000   00000            ${NORM}\n"
  printf "${RED}             00000000000      0000      00000000000       000000000000       0000000000000             ${NORM}\n"
  printf "${RED}               000000000      0000      008000000            00000000          000000000               ${NORM}\n"
  printf "\n"
  printf "${YELLOW}                       Author: cbeye Last update:25/08/20                                           ${NORM}\n"
  printf "\n"
  printf "${YELLOW}         Your TMP dir is: ${tmp_dir}                                                                ${NORM}\n"
}

function get_auth_token
{
    printf "\n"
    printf "\n"
    printf "${YELLOW}Welcome to the DNA Center deletion tool${NORM}\n"
    printf "\n"
    printf "${YELLOW}Lets gather all needed authentication data!${NORM}\n"
    printf "\n"
    printf "${YELLOW}+++++++++++++++++++++++++++++++++++++++++++++++++++${NORM}\n"
    printf "${BLUE}                        DNA-C                        ${NORM}\n"
    printf "${YELLOW}+++++++++++++++++++++++++++++++++++++++++++++++++++${NORM}\n"
    read -p "Enter Username: " dnac_username
    read -s -p "Enter Password: " dnac_password
    printf "\n"
    printf "\n"
    DNAC_TOKEN=`curl -k -u ${dnac_username}:${dnac_password} -X POST --insecure -s https://${DNAIP}/api/system/v1/auth/token 2>&1 | awk -F '"' '{print $4}'`
    printf "${YELLOW}Your DNA-C token is: ${GREEN}${DNAC_TOKEN}${NORM}\n"
    printf "\n"
    printf "\n"
    printf "${BLUE}Press ENTER to continue!${NORM}\n"
}

function delete_devices
{
    printf "${YELLOW}Getting devices data...${NORM}\n"
    curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/network-device --insecure -s | jq '.' > ${tmp_dir}/temp_get_dna_devices

    printf "${YELLOW}###############################${NORM}\n"
    printf "${YELLOW}   Start deleting devices...   ${NORM}\n"
    printf "${YELLOW}###############################${NORM}\n"
    DEVICE_COUNT=`curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/network-device/count --insecure -s | jq '.' | grep response | awk '{print $2}' | sed 's/.$//'`
    #FILE_DEVICE_COUNT=`cat ${tmp_dir}/temp_get_dna_devices | grep -i \"id\" | wc -l`
    #if [ ${DEVICE_COUNT} -eq ${FILE_DEVICE_COUNT} ]
        #then   
            #printf "${GREEN}MATCHING! EXPORTED DEVICES ${FILE_DEVICE_COUNT} DEVICE COUNT ${DEVICE_COUNT} ${NORM}\n"
            COUNTER=1
            while read device_id; 
                do    
                    printf "${YELLOW}$COUNTER / ${DEVICE_COUNT} DEVICE $device_id will be deleted ${NORM}\n"
                    COUNTER=$((COUNTER+1))
                    echo "curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" --request DELETE https://${DNAIP}/dna/intent/api/v1/network-device/${device_id}?isForceDelete=yes --insecure -s"
                    sleep 1
                    if (( $COUNTER % 100 == 0 ))           
                        then
                            printf "${GREEN} Generate new token...${NORM}\n"
                            DNAC_TOKEN=`curl -k -u ${dnac_username}:${dnac_password} -X POST --insecure -s https://${DNAIP}/api/system/v1/auth/token 2>&1 | awk -F '"' '{print $4}'`
                            #echo $DNAC_TOKEN
                    fi
                    printf "\n"
                done < <(cat ${tmp_dir}/temp_get_dna_devices | grep -i \"id\" | awk -F '"' '{print $4}')
        #else
            #printf "${RED}NOT MATCHING! EXPORTED DEVICES ${FILE_DEVICE_COUNT} DEVICE COUNT ${DEVICE_COUNT} ${NORM}\n"
    #fi
    printf "\n"

    curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/network-device --insecure -s | jq '.' > ${tmp_dir}/temp_get_dna_devices
    FILE_DEVICE_COUNT=`cat ${tmp_dir}/temp_get_dna_devices | grep -i \"id\" | wc -l`
    if [ $FILE_DEVICE_COUNT -ne 0 ]
        then 
            printf "${RED}Not done yet... getting new devices until all devices has been deleted!${NORM}\n"
            delete_devices
         else
            printf "${GREEN}DONE! Alle devices has been deleted...${NORM}\n"
    fi
}

function delete_building
{ 
    printf "${YELLOW}Getting buildings data...${NORM}\n"
    curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/site?type=building --insecure -s | jq '.' > ${tmp_dir}/temp_get_dna_building

    printf "${YELLOW}###############################${NORM}\n"
    printf "${YELLOW}  Start deleting BUILDINGS ... ${NORM}\n"
    printf "${YELLOW}###############################${NORM}\n"
    COUNTER=1
    while read building_id; 
        do   
            printf "${YELLOW}$COUNTER BUILDING $building_id will be deleted ${NORM}\n"
            COUNTER=$((COUNTER+1))
            echo "curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" --request DELETE https://${DNAIP}/dna/intent/api/v1/site/${building_id} --insecure -s"
            sleep 1
            if (( $COUNTER % 100 == 0 ))           
                then
                    echo "Reauth..."
                    DNAC_TOKEN=`curl -k -u ${dnac_username}:${dnac_password} -X POST --insecure -s https://${DNAIP}/api/system/v1/auth/token 2>&1 | awk -F '"' '{print $4}'`
                    #echo $DNAC_TOKEN
            fi
            printf "\n"
        done < <(cat ${tmp_dir}/temp_get_dna_building | grep -i \"id\" | awk -F '"' '{print $4}')
    printf "\n"

    curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/site?type=building --insecure -s | jq '.' > ${tmp_dir}/temp_get_dna_building
    FILE_BUILDING_COUNT=`cat ${tmp_dir}/temp_get_dna_building | grep -i \"id\" | wc -l`
    if [ $FILE_BUILDING_COUNT -ne 0 ]
        then 
            printf "${RED}Not done yet... getting new buildings until all devices has been deleted!${NORM}\n"
            delete_building
         else
            printf "${GREEN}DONE! Alle buildings has been deleted...${NORM}\n"
    fi
}

function delete_area
{
    printf "${YELLOW}Getting areas data...${NORM}\n"
    curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/site?type=area --insecure -s | jq '.' > ${tmp_dir}/temp_get_dna_area

    printf "${YELLOW}###############################${NORM}\n"
    printf "${YELLOW}     Start deleting AREAS ...  ${NORM}\n"
    printf "${YELLOW}###############################${NORM}\n"
    COUNTER=1
    while read area_id; 
        do   
            printf "${YELLOW}$COUNTER AREA $area_id will be deleted ${NORM}\n"
            COUNTER=$((COUNTER+1))
            echo "curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" --request DELETE https://${DNAIP}/dna/intent/api/v1/site/${area_id} --insecure -s"
            sleep 1
            if (( $COUNTER % 100 == 0 ))           
                then
                    echo "Reauth..."
                    DNAC_TOKEN=`curl -k -u ${dnac_username}:${dnac_password} -X POST --insecure -s https://${DNAIP}/api/system/v1/auth/token 2>&1 | awk -F '"' '{print $4}'`
                    #echo $DNAC_TOKEN
            fi
            printf "\n"
        done < <(cat ${tmp_dir}/temp_get_dna_area | grep -i \"id\" | awk -F '"' '{print $4}')
    printf "\n"

    curl --header "Content-Type:application/json" --header "Accept:application/json" --header "x-auth-token:${DNAC_TOKEN}" -X GET https://${DNAIP}/dna/intent/api/v1/site?type=area --insecure -s | jq '.' > ${tmp_dir}/temp_get_dna_area
    FILE_AREA_COUNT=`cat ${tmp_dir}/temp_get_dna_area | grep -i \"id\" | wc -l`
    if [ $FILE_AREA_COUNT -ne 0 ]
        then 
            printf "${RED}Not done yet... getting new areas until all devices has been deleted!${NORM}\n"
            delete_area
         else
            printf "${GREEN}DONE! Alle areas has been deleted...${NORM}\n"
    fi
}

function exit_abnormal
{          
  printf "${RED}!!!!! OH nooooo ... something went wrong! Try again! !!!!!${NORM}\n"
  help
  exit 1
} 

header

if [ "$#" == "0" ]
  then
    help
	else
    while getopts "d:hxyz" opt
    do
      case $opt in
        d) DNAIP="${OPTARG}"
           echo "DNA-Center IP is: ${DNAIP}" 
           get_auth_token
            ;;
        h) help
            ;;
        x) delete_devices
            ;;
        y) delete_building
            ;;
        z) delete_area
            ;;
      esac
    done
    shift $(($OPTIND -1))
fi