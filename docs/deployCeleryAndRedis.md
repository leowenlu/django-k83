---
Date: 9-11-2020
Title: Celer And Redis to K8S
Tags:
    - Kubernetes
    - Celery
    - Redis
---
Reference links:
* [Celery and Django](https://docs.celeryproject.org/en/stable/django/first-steps-with-django.html)
* [Redis](https://redis.io/)
## Nacessary change with the code
1.  *code/requiements.txt*, replace the content with the following:

```
celery==4.4 #flower doesn't support celery5
django
vine<5.0.0
psycopg2-binary
django-health-check
django-redis
kombu==4.6.11
redis
```    
There are a few modules listed above, we need install them in order to make django and celery redis working.



2. config and setup locally in **virtualenv**
    navigate to your project folder and then install required modules
     ```
     source  ~/py-env/django-k8s/bin/activate ~/py-env/django-k8s/bin/
     pip install -r requirements.txt
     ```
3.  *code/core/celery.py* content

    ``` python
    import os
    from celery import Celery
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
    app = Celery('core')
    app.config_from_object('django.conf:settings', namespace='CELERY')
    app.autodiscover_tasks()
    ```
4. *code/core/__init__.py* 
        
    ``` python
    from .celery import app as celery_app
    __all__ = ('celery_app',)
    ```    
## Tess in virtualenv 
type the following commands to check if everything is working so far.
``` bash
# python manage.py runserver
celery -A core beat -l debug
celery -A core worker -l info
```
**NOTE:** As Django is using postgres which is a pod in K8S, so will not able to test it locally at the moment. 


## Deploy changes to K8S

Deployment yaml file changes
* Remove `CMD ["python", "manage.py","runserver","0.0.0.0:8000"]` off *Dockerfile*
* Add `command: ["python", "manage.py","runserver","0.0.0.0:8000"]` to *deploy/django/deployment.yml* 
`docker build -t mu00157969x/leo-django:v2 .`

* deploy celery and redis

    ```
    kubectl apply -f deploy/celery/beat-deployment.yaml 
    kubectl apply -f deploy/celery/worker-deployment.yaml 
    kubectl apply -f deploy/redis/deployment.yaml 
    kubectl apply -f deploy/redis/service.yaml  
    ```
