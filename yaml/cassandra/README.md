# Cassandra
 To create cassandra petset clusters

##1. Not Using Persistent Volume
 When you delete your pods, the volumes also remove

####a) edit cassandra-petset_local.yaml  
 You can customize this file
	
 <https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/cassandra/cassandra-petset-local.yaml>


####b) create cassandra petset cluster

 	$ kubectl create -f yaml/cassandra/cassandra-petset-local.yaml

####c) check cassandra cluster status

	$ kubectl exec -it cassandra-0 nodetool status

####d) delete cassandra petset cluster 
	$ kubectl delete petset cassandra
	$ kubectl delete service cassandra
	$ kubectl delete pod cassandra-0

####e) scale out cassandra petset cluster
	$ kubectl edit petset cassandra

 Then you can edit replicas count on petset yaml  
 After editing replicas, cassandra nodes will change immediately 


##2. Using Persistent Volume  

 Even though you delete your pods, the volumes remain

 I've used google container image but it has bug  
 (this bug affect only when you create petset cluster with persistent volume)  
 For avoiding the bug, I use another image

###1) Using dynamic Persistent Volume
 Most steps are same with "Not using Persistent Volume" steps    
 
####a) edit cassandra-petset_pv.yaml   
 You should refer to this file for Using Persistent Volume
 <https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/cassandra/cassandra-petset-pv.yaml>

####b) create cassandra petset cluster  

	$ kubectl create -f yaml/cassandra/cassandra-petset-pv.yaml

 In this case, the volume create automatically  
 But you cannot choose the volume type and filesystem. (volume default : standard persistent volume(gce), gp2(aws))  

 Even though you delete pods and petset , the volumes remain    
 Also you can find your volume on your GCE disks  

	$ kubectl get pv
	$ kubectl get pvc
	$ gcloud compute disks list
	$ aws ec2 describe-volumes


###2) Using SSD persistent disk as Persistent Volume  

 As I said before, when you use the persistent volume, you cannot choose the volume type  
 There is a way to modify volume type  
 You should refer this link.(https://github.com/kubernetes/kubernetes/issues/23525)  

 After do this, you can just create petset cluster  
 Even though modifying the code , you cannot choose the volume type  
 It is just updated default volume type 

 Otherwise when you want to use SSD persistent disks as PV, you should create SSD disks in advance  
 (Cassandra recommend to use SSD)

####a) create persistent volume 

 You can create volume and generate persistent volume yaml using create_volume.sh  
 This shell is not completed. You should check the result files  
 Also, Don't forget that there is naming rule when you create Persistent Volume Claim  

 	Syntax> ./create_volume.sh cloudtype volume_count volume_size volume_type volume_zone fs_type prefix"
 	$ ./create_volume.sh
 	$ ./create_volume.sh gce 3 50 pd-ssd us-central1-b ext4 test
 	$ ./create_volume.sh aws 3 50 gp2 us-west-2a ext4
 	$ cd yaml 
 	$ cat pv_result_$date.yaml
 	
  After checking the yaml file, you can create Persistent Volume.

 	$ kubectl create -f yaml/pv_result_$date.yaml

####b) create persistent volume claim

 Generally pvc_nm is volumeClaimTemplates's name and cluster name 

 	Syntax> ./pvc_generator.sh pvc_nm vol_count vol_size "
 	$ ./pvc_generator.sh
 	$ ./pvc_generator.sh cassandra-data-cassandra 3 50"

 After checking the yaml file, you can create Persistent Volume.

 	$ kubectl create -f yaml/pvc_result_$date.yaml

####c) create petset cluster  

 Then, you can create petset cluster.

 	$ kubectl create -f yaml/cassandra/cassandra-petset-pv.yaml
	
####d) delete persistent volume, persistent volume claim
 In this case, When you delete petset cluster, the Persistent Volume, Persistent Volume Claim remains.  
 So if you want to delete all about the petset cluster and volume, you should delete Persistent Volume and Persistent Volume Claim.

 	$ kubectl delete pv $pv_name
 	$ kubectl delete pvc $pvc_name

