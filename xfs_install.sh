#!/bin/bash
#to install xfsprogs on k8s nodes

zone=$2
ig_nm=$3
cluster_nm=$2"/"$3
dt=`date +"%Y%m%d%H"`
FILE1=xfs_update_result_$dt.log

if [ -f $FILE1 ];
then
   mv $FILE1 $FILE1.bak
fi

if [ "$1" == "" ]
then 

	echo "=============================================="
	echo "Syntax> ./xfs_install.sh cloud_type zone(gce only) instance_group_name(gce only) "
	echo "Example> ./xfs_install.sh aws "
	echo "Example> ./xfs_install.sh gce asia-east1-b cassandra-example-qk21wfd"
	echo "=============================================="

else
    if [ "$1" == "aws" ]
      then
 	set -f; IFS=$'\n'
	acmd=(`kubectl get nodes | awk 'NR > 1 {print "kubectl describe nodes "$1" | grep Addresses " }'`)

	for each in "${acmd[@]}"
	do
           result=$(eval "$each") 
           ip=$(echo $result | cut -d',' -f3)
           ssh -i ~/.ssh/kube_aws_rsa admin@$ip 'bash -s' < ./xfs.sh >> ./xfs_update_result_$dt.log
	   echo "done!"
        done
    elif [ "$1" == "gce" ]
      then
        set -f; IFS=$'\n'
	gcmd=(`gcloud compute instance-groups list-instances $cluster_nm | awk -v var=$zone 'NR > 1 {print "gcloud compute ssh "var"/"$1 " '\''bash -s'\'' < ./xfs.sh"}'`)

	for each in "${gcmd[@]}"
	do
               	eval "$each" >> ./xfs_update_result_$dt.log
	        echo "done!"
        done
    else
        echo "you should input the cloud type (gce or aws)"
    fi
fi       
