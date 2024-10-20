from django.urls import path
from . import views

urlpatterns = [
    path('led/', views.led_control, name='led_control'),
    path('led/status', views.get_led_status, name='get_led_status'),  # LED 제어를 위한 엔드포인트
    path('circulator/',views.circulator_control, name='circulator_control'),
    path('circulator/temperature_humidity', views.get_temperature_humidity, name = 'get_temperature_humidity')
]