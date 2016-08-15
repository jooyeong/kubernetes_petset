#!/bin/bash
# create volumes and generate pv.yaml
function readJson {  
  UNAMESTR=`uname`
  if [[ "$UNAMESTR" == 'Linux' ]]; then
    SED_EXTENDED='-r'
  elif [[ "$UNAMESTR" == 'Darwin' ]]; then
    SED_EXTENDED='-E'
  fi; 

  VALUE=`grep -m 1 "\"${2}\"" ${1} | sed ${SED_EXTENDED} 's/^ *//;s/.*: *"//;s/",?//'`

  if [ ! "$VALUE" ]; then
    echo "Error: Cannot find \"${2}\" in ${1}" >&2;
    exit 1;
  else
    echo $VALUE ;
  fi; 
}

dt=`date +"%Y%m%d%H"`
vol_cnt=$2
vol_prefix=$7
fs_type=$6

FILE1=yaml/pv_result_aws_$dt.yaml
FILE2=yaml/pv_result_gce_$dt.yaml

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

if [ "$fs_type" == "" ];
then
vol_prefix="ext4"
fi

if [ "$vol_prefix" == "" ];
then
vol_prefix="kube"
fi

if [ "$1" == "" ]
then 
  echo "** This is for creating multi persistent disks"
  echo "** How to use this shell"
  echo "** To show volume zone on gce : gcloud compute zones list"
  echo "** To show volume type on gce : gcloud compute disk-types list"
  echo "** To show volume zone on aws : aws ec2 describe-availability-zones"
  echo "==================================================="
  echo "Syntax> ./create_volume.sh cloud_type volume_count volume_size volume_type volume_zone fs_type(optional) prefix(optional,only for gce)"
  echo "example> ./create_volume.sh gce 3 50GB pd-ssd us-central1-b ext4 test"
  echo "example> ./create_volume.sh aws 3 50 gp2 us-west-2a ext4"
  echo "==================================================="

else
  if [ "$1" == "aws" ]
  then
    echo "Start to create volume on AWS"
      if [ -f ebs_$dt.log ] 
        then
           echo "ebs_$dt.log exists. I will create backup file" 
           mv ebs_$dt.log ebs_$dt.log.bak
      else 
           echo "go!"
      fi
   
      for ((i=1; i<=$vol_cnt; i++)); do
        aws ec2 create-volume --size $3 --availability-zone $5 --volume-type $4 > ebs_tmp_$dt.log
        volID=`readJson ebs_tmp_$dt.log VolumeId` 
        echo $volD >> ebs_$dt.log 
  
        sed -e "s;%vol_nm%;$volID;g" -e "s;%vol_size%;$3;g" -e "s;%fs_type%;$fs_type;g" template/pv_template_aws.yaml >> yaml/pv_result_aws_$dt.yaml
      done
      rm ebs_tmp_$dt.log
      echo "done!"

  elif [ "$1" == "gce" ]
  then
    echo "Start to create volume on GCE"
      if [ -f disk_$dt.log ]
        then
           echo "disk_$dt.log exists."
           mv disk_$dt.log disk_$dt.log.bak
      else
           echo "go!"
      fi
  
    for ((i=0; i<$vol_cnt; i++)); do
      vol_nm+=$vol_prefix"-"$i" "
      echo $vol_prefix"-"$i >> disk_$dt.log
    
      sed -e "s;%vol_nm%;$vol_prefix"-"$i;g" -e "s;%vol_size%;$3Gi;g" -e "s;%fs_type%;$6;g" template/pv_template_gce.yaml >> yaml/pv_result_gce_$dt.yaml
    done

    gcloud compute disks create  $vol_nm --size $3 --type $4 --zone $5   
    echo "done!"
   
  else
    echo "This shell support aws, gce!"
  fi
fi
