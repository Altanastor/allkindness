from django.shortcuts import render


def index(request):

    context = {}

    template_name = 'page/index.html'
    return render(request, template_name, context)
