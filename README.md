
# Prerequisites
* Docker
You need docker installed, here it is [link] https://docs.docker.com/get-docker/
* Minikube
minikube is a local kubernetes, makes it easy to develop in kubernetes. [link https://minikube.sigs.k8s.io/docs/start/ ]
docker desktop is another option [link https://docs.docker.com/desktop/ ]

# Run  App Locally 
Very first we will setup the django web app to run on our locally. [Here](./docs/RunTheAppLocally.md)
# Containerize Django App
Everything is working as expected in python virtualenv, now let's put it in a contianer.[Here](./docs/ContainerizeDjangoApp.md)
# Deploy Django To Kubernetes
After we have made webApp running in a contianer, we then will deploy it to Kubernetes.[Here](./docs/DeployDjangoToKubernetes.md)
# postgres database as docker to Kubernetes
Postgres database will run in a container, as the Docker containers useare ephemeral in nature so persistent storage volume needed. Details [Here](./docs/postgresWithPersistentVolume.md)  
# Containerize Celery, and Redis with Docker.