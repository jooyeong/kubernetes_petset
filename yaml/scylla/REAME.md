# Scylla

To create scylla petset clusters

Scylla is a cassandra compatible NoSQL column store  

Unfortunately, There is no Scylla Docker Image for kubernetes  
So it is difficult to configure env variables  
Also Scylla does not support KubernetesSeedProvider yet   

Therefore there are some constraints to deploy scylla cluster using kubernetes  
I don't recommend this way for production but you can try to deploy scylla cluster for test   

* The important constraint is to configure seed node   
This way is to configure only 1 seed node in scylla.yaml and it is the first pod on petset cluster  
So when the first pod is dead, it can be occured the problem  


##1. Not Using Persistent Volume
 When you delete your pods, the volumes also remove  
 It has almost same steps with cassandra  
 But I recommend that the other pods create after the first pod create in advance  

#####a) edit scylla-petset-local.yaml  
  you can edit yaml file  
 ** At first I recommend to configure replicas=1  
	
 <https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/scylla/scylla-petset-local.yaml>

#####b) create scylla petset cluster  

	$ kubectl create -f yaml/scylla/scylla-petset-local.yaml

#####c) scale out scylla petset cluster
	$ kubectl edit petset scylla

#####d) check scylla cluster status

	$ kubectl exec -it scylla-0 nodetool status

#####e) delete scylla petset cluster 
	$ kubectl delete petset scylla
	$ kubectl delete service scylla
	$ kubectl delete pod scylla-0


 Then you can edit replicas count on petset yaml.  
 After editing replicas, scylla nodes will change immediately 


##2. Using Persistent Volume

 Even though you delete your pods, the volumes remain

###1) Using dynamic Persistent Volume  
 Most steps are same with "Not using Persistent Volume" steps  

#####a) edit scylla-petset-pv.yaml  
 You should refer to this file for Using Persistent Volume  
 <https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/scylla/scylla-petset-pv.yaml>
 
#####b) create scylla petset cluster

	$ kubectl create -f yaml/scylla/scylla-petset-pv.yaml

 In this case, the volume create automatically  
 But you cannot choose the volume type and filesystem. (volume default : standard persistent volume(gce), gp2(aws))

 Even though you delete pods and petset , the volumes remain    
 Also you can find your volume on your GCE disks

	$ kubectl get pv
	$ kubectl get pvc
	$ gcloud compute disks list
	$ aws ec2 describe-volumes


###2) Using SSD persistent disk as Persistent Volume

 Scylla recommend to use SSD and xfs filesystem. 

 As I said before, you cannot choose the volume type as well as filesystem.  
 So when you want to use SSD persistent disks and xfs filesystem as PV, you should create disks in advance.    

 * Also, you should install xfsprogs on kubernetes nodes for using xfs filesystem.  

####a) install xfsprog on kubernetes nodes

	Syntax> ./xfs_install.sh cloud_type zone(gce only) instance_group_name(gce only)
	$ ./xfs_install.sh
	$ ./xfs_install.sh gce asia-east1-c  gke-cassandra-test01-default-pool-56c12390d-grp
	$ ./xfs_install.sh aws


####b) create persistent volume

 And then you can create volume and generate persistent volume yaml using create_volume.sh      
 This shell is not completed. You should check the result files  
 Also, Don't forget that there is naming rule when you create Persistent Volume Claim  

	Syntax> ./create_volume.sh cloudtype volume_count volume_size volume_type volume_zone fs_type prefix"
	$ ./create_volume.sh
	$ ./create_volume.sh gce 3 50 pd-ssd us-central1-b ext4 test
	$ ./create_volume.sh aws 3 50 gp2 us-west-2a ext4  
	
 After checking the yaml file, you can create Persistent Volume

	$ kubectl create -f yaml/pv_result_$date.yaml

####c) create persistent volume claim

 Generally pvc_nm is volumeClaimTemplates's name and cluster name 

	Syntax> ./pvc_generator.sh cloud_type pvc_nm vol_count vol_size "
	$ ./pvc_generator.sh
	$ ./pvc_generator.sh gce scylla-data-scylla 3 50"

 After checking the yaml file, you can create Persistent Volume Claim

	$ kubectl create -f yaml/pvc_result_$date.yaml

####d) create petset cluster

 Then, you can create petset cluster.

	$ kubectl create -f yaml/scylla/scylla-petset-pv.yaml

####e) delete persistent volume, persistent volume claim

 In this case, When you delete petset cluster, the Persistent Volume, Persistent Volume Claim remains.  
 So if you want to delete all about the petset cluster and volume, you should delete Persistent Volume and Persistent Volume Claim.

	$ kubectl delete pv $pv_name
	$ kubectl delete pvc $pvc_name
