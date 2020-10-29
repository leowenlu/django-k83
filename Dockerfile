FROM python:3.8-slim
ENV PROJECT_ROOT /code
WORKDIR $PROJECT_ROOT
COPY code/ $PROJECT_ROOT
RUN pip install django
CMD ["python", "manage.py","runserver","0.0.0.0:8000"]