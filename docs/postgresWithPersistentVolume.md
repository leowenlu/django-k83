--- 
[](
    key1: value1
    key2: value2
)
Author: Leo Li
Date: 7-11-2020
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
**NOTE** 
1. `user` and `password` in *secrets.yaml* need be encoded with `base64`
2. Security concerns, `base64` is not considered as `encryption`. The encoding is entirely well known, the algorithm is simple and as it has not "mutability" of the algorithm or concept of keys etc. it is not considered as "encryption".
3. Bad idea to push *secrets.yaml* to you repo for security reason.

## deploy postgres 

``` bashTerminal
 kubectl apply -f deploy/postgres/deployment.yaml 
```
output should be:

`deployment.apps/postgres created`


## Deploy service 

``` bashTerminal
kubectl apply -f deploy/postgres/service.yaml 
```

**Using Secrets as environment varialbes**
Multiple Pods can reference the same secret.

The container definition int *services.yaml* as bellow:

``` yaml
  env:
    - name: POSTGRES_USER
      valueFrom:
        secretKeyRef:
          name: postgres-credentials
          key: user
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: postgres-credentials
          key: password
    - name: POSTGRES_DB
      value: kubernetes_django
```
Let's take a look at what env in postgres container:

```
kubectl exec --stdin --tty postgres-db79cc55d-wxg5d -- /bin/bash

root@postgres-db79cc55d-wxg5d:/# printenv
HOSTNAME=postgres-db79cc55d-wxg5d
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
POSTGRES_DB=kubernetes_django
TERM=xterm
PG_MAJOR=9.6
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.96.0.1
POSTGRES_PASSWORD=replaceWithYourPassword
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/postgresql/9.6/bin
PWD=/
LANG=en_US.utf8
POSTGRES_USER=replaceWithUsername
SHLVL=1
HOME=/root
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
PG_VERSION=9.6.6-1.pgdg80+1
PGDATA=/var/lib/postgresql/data
GOSU_VERSION=1.10
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
_=/usr/bin/printenv
```
You can see environment variables `POSTGRES_PASSWORD` `POSTGRES_USER` and `POSTGRES_DB` and their values.
In the API server, secret data is stored in etcd, so be cautious with it, detail please see [Here](https://kubernetes.io/docs/concepts/configuration/secret/#risks)
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

## config django to use postgres database

```mermaid 

graph TD;
A-->B;
A-->C;
B-->D;
C-->D;
```