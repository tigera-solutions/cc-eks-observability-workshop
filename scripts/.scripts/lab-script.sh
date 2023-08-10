#!/bin/bash

typeset -i OPTION
OPTION=0
KU="/usr/local/bin/kubectl"
BSCRIPTS="/home/tigera/Calico-Security-Observability-Troubleshooting-Training/tsworkshop/workshop1/.scripts/.blab"
FSCRIPTS="/home/tigera/Calico-Security-Observability-Troubleshooting-Training/tsworkshop/workshop1/.scripts/.flab"


clear
while [ $OPTION -ne 99 ]
do

  echo ""	
  echo " ---------------------------- Break Scripts"
  echo ""
  echo "################################################################################"
  echo "#                                                                              #"
  echo "# 1 - Demo Break Online Boutique - Dynamic Service and Threat Graph            #"
  echo "#                                                                              #"
  echo "# 2 - LAB Break Online Boutique - Dynamic Service and Threat Graph             #"
  echo "#                                                                              #"
  echo "# 3 - Demo Break Online Boutique - Flow Visualisation                          #"
  echo "#                                                                              #"
  echo "# 4 - LAB Break Online Boutique - Flow Visualisation                           #"
  echo "#                                                                              #"
  echo "# 5 - Demo Break Online Boutique - Kibana                                      #"
  echo "################################################################################"
  echo ""
  echo " ---------------------------- Fix Scripts"
  echo ""
  echo "################################################################################"
  echo "#                                                                              #"
  echo "# 21 - LAB Fix Online Boutique - Dynamic Service and Threat Graph              #"
  echo "#                                                                              #"
  echo "# 41 - LAB Fix Online Boutique - Flow Visualisation                            #"
  echo "#                                                                              #"
  echo "# 61 - LAB Fix Online Boutique - Kibana                                        #"
  echo "################################################################################"
  echo ""
  echo "99 - Exit"
  echo ""
  read  -p "Enter the option: " OPTION

  case $OPTION in
	1|2|4|5|7|8)
                $KU replace -f $BSCRIPTS$OPTION".yaml" > /dev/null
                echo ""
                read -p "------------- Press any key to continue"
                clear
                ;; 
	3|6)
		$KU replace -f $BSCRIPTS$OPTION".yaml" > /dev/null
                echo ""
		$KU rollout restart daemonset ingress-nginx-controller -n ingress-nginx > /dev/null
		echo "------------- Waiting for the config to be applied"
		sleep 80
		echo ""
                read -p "------------- Press any key to continue"
                clear
                ;;
	9)
		sudo sed -i 's/FELIX_FAILSAFEOUTBOUNDHOSTPORTS=\"tcp:0.0.0.0\/0:22,/FELIX_FAILSAFEOUTBOUNDHOSTPORTS=\"/g' /etc/calico/calico.env 
		sudo systemctl restart calico.service 
		$KU replace -f $BSCRIPTS$OPTION".yaml" > /dev/null
                echo ""
                read -p "------------- Press any key to continue"
                clear
                ;;	
        10)	
		$KU delete deployment tigera-firewall-controller -n tigera-firewall-controller > /dev/null 2>&1 
		$KU  delete secrets tigera-pull-secret -n tigera-firewall-controller  > /dev/null 2>&1
		sleep 3
		if [[ -z $(ssh worker1 sudo docker image ls | grep firewall-integration) ]]
	       	then 
			$(ssh worker2 sudo docker image rm $(ssh worker2 sudo docker image ls | grep firewall-integration | awk '{print $3}')) > /dev/null 2>&1
	       	else 
			$(ssh worker1 sudo docker image rm $(ssh worker1 sudo docker image ls | grep firewall-integration | awk '{print $3}')) > /dev/null 2>&1 
		fi
		$KU apply -f https://docs.tigera.io/manifests/fortinet.yaml > /dev/null 2>&1 
		echo ""
                read -p "------------- Press any key to continue"
                clear
                ;;
	21|41|61|71|81)
                $KU replace -f $FSCRIPTS$OPTION".yaml" > /dev/null
                echo ""
                read -p "------------- Press any key to continue"
                clear
                ;;
	91)
		sudo sed -i 's/FELIX_FAILSAFEOUTBOUNDHOSTPORTS=\"/FELIX_FAILSAFEOUTBOUNDHOSTPORTS=\"tcp:0.0.0.0\/0:22,/g' /etc/calico/calico.env
		sudo systemctl restart calico.service
                $KU replace -f $FSCRIPTS$OPTION".yaml" > /dev/null
                echo ""
                read -p "------------- Press any key to continue"
                clear
                ;;
	101)
		$KU create secret generic tigera-pull-secret  --from-file=.dockerconfigjson=/home/tigera/config.json  --type=kubernetes.io/dockerconfigjson -n tigera-firewall-controller > /dev/null 2>&1 
		$KU rollout restart deployment tigera-firewall-controller -n tigera-firewall-controller > /dev/null 2>&1 
		echo ""
                read -p "------------- Press any key to continue"
                clear
                ;;
	99)
                clear
                ;;
	*)
		echo ""
		echo "!!!!!! Invalid Option !!!!!!!"
		sleep 1
		clear
		;;
  esac
done
