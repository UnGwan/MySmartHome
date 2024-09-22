from django.urls import path
from . import views

urlpatterns = [
    path('led/', views.led_control, name='led_control'),  # LED 제어를 위한 엔드포인트
]