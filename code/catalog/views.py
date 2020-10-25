from django.http import HttpResponse
def index(request):
    return HttpResponse("Hello, This is 'catalog' home page.")
