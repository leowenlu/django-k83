## Containerize Django Deploy To Kubernetes.md

1. create **deploy** folder for django deployments/services

    Edit **deploy/django/deployment.yml** with the following content
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django
  labels:
    app: django
spec:
  replicas: 1
  selector:
    matchLabels:
      pod: django
  template:
    metadata:
      labels:
        pod: django
    spec:
      containers:
        - name: django
          image: leoli/leo-django
          ports:
            - containerPort: 8000
          command: ["python"]
          args: ["manage.py","runserver","0.0.0.0:8000"]
```

2. service yml settings as shown below

```
kind: Service
apiVersion: v1
metadata:
  name: django-service
spec:
  selector:
    pod: django
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
  type: NodePort
```
3. deploy django deployment and service
```
kubectl apply -f deploy/django/deployment.yml
kubectl apply -f deploy/django/service.yml
```
minikube service django-service, with URL you can test if everything is working as expected.
