#Create Djanso Docker Image
## Build the docker image
We first need a docker image which has all modules we need, we also need copy our source code to the docker image to make our django app working.

Create django Dockerfile:
```
FROM python:3.8-slim
ENV PROJECT_ROOT /code
WORKDIR $PROJECT_ROOT
COPY code/ $PROJECT_ROOT
RUN pip install django
CMD ["python", "manage.py","runserver","0.0.0.0:8000"]
```
1. python:3.8-slim is relatively small, happy with this python base image.
2. the best way to install python modules is with a requirement.text file by doning `RUN pip install -r requirements.txt`

Navigate to your project folder, where is the **Dockerfile**, build the image with following command:
NOTE: if you have **minikube** install, type in `eval $(minikube docker-env)` in the terminal.
NOTE: Open **locallibrary/settings.py** find `ALLOWED_HOSTS = []` replace with  `ALLOWED_HOSTS = ['*']`
```
# leo-django is the image name in my project, hostname is lowercase
docker build -t ${HOSTNAME}/leo-django:v1 .
```
With the image tag, leave it for now, as we plan to put it in our minikube, rather than docker hub, we will use local repo.

Test if the docker image is working or not with the following command

```
docker run -itd -p 8000:8000 ${HOSTNAME}/leo-django:v1
```

If found ```Unable to find image '${yourHostname}/leo-django:v1' locally``` when run the about command, then please open another terminal, and try it again. 

With `eval $(minikube docker-env)`, you may not able to reach you webApp.

These caused by `eval $(minikube docker-env)`, then solution is you can find the image ID, and run `docker run -itd -p 8000:8000 ${imageID}/leo-django:v1`.

