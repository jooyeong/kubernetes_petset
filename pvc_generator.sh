#!/bin/sh
# to generate pvc.yaml

pvc_nm=$2
vol_cnt=$3
vol_size=$4
dt=`date +"%Y%m%d%H"`

FILE1=yaml/pvc_result_aws_$dt.yaml
FILE2=yaml/pvc_result_gce_$dt.yaml

if [ -f $FILE1 ];
then
   mv $FILE1 $FILE1.bak
fi

if [ -f $FILE2 ];
then
   mv $FILE2 $FILE2.bak
fi


if [ "$vol_cnt" == "" ];
then
   vol_cnt='0'
fi


if [ "$1" == "" ]
then 
	echo "** This is for generating pv, pvc yaml"
	echo "** How to use this shell"
	echo "** You should know your volume name prefix and size"
	echo "** Also you should know pvc(persistent volume claim) name prefix"
	echo "** Generally pvc_nm is volumeClaimTemplates's name and cluster name"
	echo "=============================================="
	echo "Syntax> ./pvc_generator.sh cloud_type pvc_nm vol_count vol_size "
	echo "Example> ./pvc_generator.sh gce cassandra-data-cassandra 3 10"
	echo "=============================================="
else
    if [ "$1" == "aws" ]
      then
	for ((i=0; i<$vol_cnt; i++)); do
    		sed -e "s;%pvc_nm%;$pvc_nm"-"$i;g" -e "s;%vol_size%;$vol_size;g" template/pvc_template_aws.yaml >> yaml/pvc_result_aws_$dt.yaml
	done

	echo "done! \nGo to yaml directory and check!"
   elif [ "$1" == "gce" ]
     then
        for ((i=0; i<$vol_cnt; i++)); do
                sed -e "s;%pvc_nm%;$pvc_nm"-"$i;g" -e "s;%vol_size%;$vol_size;g" template/pvc_template_gce.yaml >> yaml/pvc_result_gce_$dt.yaml
        done

        echo "done! \nGo to yaml directory and check!"
   else
      echo "you should input the cloud type (gce or aws)"
   fi

fi
