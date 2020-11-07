--- 
Author: Leo Li
Date: 20-11-2020
Title: Postgres With Persistent Volume
Tags:
    - Kubernetes
    - postgres
---

Kubenetes PV and PVC document is [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

## Providion PV

 PersistentVolume (PV) is a piece of storage in the cluster, it is a resource in the cluster just like a node is a cluster resource. yaml file is [here](../deploy/volume.yaml)

## Providion PVC

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. The yaml file is [here](../deploy/volume_claim.yaml)


apply *PV* and *PVC*

Let's check if everything is working so far for volume and volume-claim.


```bash
#$ kubectl describe pvc postgres-pvc
Name:          postgres-pvc
Namespace:     default
StorageClass:  standard
Status:        Bound
Volume:        postgres-pv
Labels:        type=local
Annotations:   kubectl.kubernetes.io/last-applied-configuration:
                 {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"labels":{"type":"local"},"name":"postgres-pvc","namespace"...
               pv.kubernetes.io/bind-completed: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      2Gi
Access Modes:  RWX
VolumeMode:    Filesystem
Mounted By:    <none>
Events:        <none>


#$ kubectl describe pvc postgres-pv
Name:          postgres-pvc
Namespace:     default
StorageClass:  standard
Status:        Bound
Volume:        postgres-pv
Labels:        type=local
Annotations:   kubectl.kubernetes.io/last-applied-configuration:
                 {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"labels":{"type":"local"},"name":"postgres-pvc","namespace"...
               pv.kubernetes.io/bind-completed: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      2Gi
Access Modes:  RWX
VolumeMode:    Filesystem
Mounted By:    <none>
Events:        <none>

```

## Database credentials

`Opaque` is the default Secret type if omitted from a Secret configuration file, which is arbitrary user-defined data. When you create a Secret using `kubectl`, you will use the `generic` subcommand to indicate an `Opaque`. 

You can user kubeclt command 

``` bash
$ kubectl create secret generic postgres-credentials --from-literal=user=replaceWithUsername --from-literal=password=replaceWithYourPassword
```

or

``` bash
$ echo "replaceWithYourPassword" | base64
cmVwbGFjZVdpdGhZb3VyUGFzc3dvcmQK
$  echo "replaceWithYourUsername" | base64
cmVwbGFjZVdpdGhZb3VyVXNlcm5hbWUK

$ kubectl apply -f deploy/postgres/secrets.yaml
secret/postgres-credentials created

$ kubectl get secret postgres-credentials
NAME                   TYPE     DATA   AGE
postgres-credentials   Opaque   2      25s

```
**NOTE** `user` and `password` in *secrets.yaml* need be encoded with `base64`

## deploy postgres 

``` bash
x:$ kubectl apply -f deploy/postgres/deployment.yaml 
deployment.apps/postgres created


$ kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
postgres   1/1     1            1           36s

```

## service 

   ``` bash
$ kubectl apply -f deploy/postgres/service.yaml 
#service/postgres-service created
```



## test

as I am using `minikube` in my lab, so **minikube service django-service** can help me to get the URL and help us to test the service in browser.


``` bash
$ kubectl get services
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
django-service     NodePort    10.106.176.104   <none>        8000:30741/TCP   18m
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP          6h45m
postgres-service   ClusterIP   10.96.128.196    <none>        5432/TCP         63m


minikube service django-service
|-----------|----------------|-------------|----------------------------|
| NAMESPACE |      NAME      | TARGET PORT |            URL             |
|-----------|----------------|-------------|----------------------------|
| default   | django-service |             | http://192.168.64.12:30741 |
|-----------|----------------|-------------|----------------------------|
🎉  Opening service default/django-service in default browser...

```
