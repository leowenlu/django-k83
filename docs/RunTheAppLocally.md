
## Create django project and App in python virtualenv 
create python env
```
virtualenv django-k8s
source  ~/py-env/django-k8s/bin/activate ~/py-env/django-k8s/bin/
Pip install django
```
create django project and app
```
mkdir code
django-admin startproject core code
```
'core' is the site name I will use, with the following command we can create the first app 'catalog' :
`python manage.py startapp catalog`
The updated project directory should now look like this:
 ```
        ├── catalog
        │   ├── __init__.py
        │   ├── admin.py
        │   ├── apps.py
        │   ├── migrations
        │   │   └── __init__.py
        │   ├── models.py
        │   ├── tests.py
        │   └── views.py
        ├── core
        │   ├── __init__.py
        │   ├── __pycache__
        │   │   ├── __init__.cpython-37.pyc
        │   │   └── settings.cpython-37.pyc
        │   ├── asgi.py
        │   ├── settings.py
        │   ├── urls.py
        │   └── wsgi.py
        └── manage.py
```

Try if everything is working as expected so far
``` 
    python manage.py runserver
    Watching for file changes with StatReloader
    Performing system checks...

    System check identified no issues (0 silenced).

    You have 18 unapplied migration(s). Your project may not work properly until you apply the migrations for app(: admin, auth, contenttypes, sessions.
    Run 'python manage.py migrate' to apply them.
    October 24, 2020 - 09:16:31
    Django version 3.1.2, using settings 'core.settings'
    Starting development server at http://127.0.0.1:8000/
    Quit the server with CONTROL-C.
```
Open your browser, and http://127.0.0.1:8000/catalog/ , you should be able to see the django rocket.

## django hello world
1. Open the project settings file, **core/settings.py**, and add 'catalog' to `INSTALLED_APPS`
2. Other project settings
    There are some setings you do need pay attention to, ref: [django] (https://docs.djangoproject.com/en/3.1/topics/settings/)
    * `TIME_ZONE`
    *  `SECRET_KEY`
    * `DEBUG`
    * `ALLOWED_HOSTS`
3. First view


```python
from django.http import HttpResponse
def index(request):
    return HttpResponse("Hello, This is 'catalog' home page.")
```

4. new urls.py for 'catalog'
```python
from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
]
```

4. Hooking up the URL mapper
Open **core/urls.py** and import ``` from django.urls import include ``` and append  ```path('catalog/', include('catalog.urls'))``` to ```urlpatterns```,  it will look like the following:

``` python
from django.contrib import admin
from django.urls import path
from django.urls import include
urlpatterns = [
    path('admin/', admin.site.urls),
    path('catalog/', include('catalog.urls'))
]
```

It's now time to have a test if every thing is working as expected so far, then we can pack our code and build our docker image.

Open your browser, http://127.0.0.1:8000/catalog/, you should be able to see your App is up and running.

