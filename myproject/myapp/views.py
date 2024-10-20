
import subprocess
import Adafruit_DHT as dht
from django.shortcuts import render

# views.py
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from gpiozero import LED

# GPIO 12번 핀에 연결된 LED 객체 생성
led = LED(12)


#온습도 모드
@csrf_exempt
def get_temperature_humidity(request):
    SENSOR =  dht.DHT22
    PIN = 4
    humidity, temperature = dht.read_retry(SENSOR, PIN)

    if humidity is not None and temperature is not None:
        data = {
            'temperature': temperature,
            'humidity': humidity,
        }
        return JsonResponse(data)
    else:
        return JsonResponse({'error': 'Failed to retrieve data from sensor'}, status=500)

#서큘레이터 제어
@csrf_exempt
def circulator_control(requset):
    key_mapping = {
        "P": "KEY_POWER",
        "U": "KEY_U",
        "D": "KEY_D",
        "M": "KEY_M",
        "T": "KEY_T",
        "A": "KEY_A",
        "G": "KEY_G",
        "S": "KEY_S"
    }
    if requset.method == "POST":
        action = requset.POST.get("action",'')
        
        if action in key_mapping:
            try: 
                subprocess.run(["irsend","SEND_ONCE","power",key_mapping[action]], check = True)
                return JsonResponse({'status': 'success', 'message': f'Circulator turned {key_mapping[action]}'})
            except subprocess.CalledProcessError as e :
                return JsonResponse({'status': 'error', 'message': 'Failed to control the circulator'})
        else:
            return JsonResponse({'status': 'error', 'message': "Invalid mode provided. Please enter a valid mode."})
    

#led 제어 
@csrf_exempt
def led_control(request):
    if request.method == 'POST':
        # 요청에서 action 값을 가져옴 (예: "on" 또는 "off")
        action = request.POST.get('action', '')
        # LED 제어 로직
        if action == 'on':
            led.on()
            return JsonResponse({'status': 'success', 'message': 'LED가 켜졌습니다.'})
        elif action == 'off':
            led.off()
            return JsonResponse({'status': 'success', 'message': 'LED가 꺼졌습니다.'})
        else:
            return JsonResponse({'status': 'failed', 'message': '올바른 액션 값이 아닙니다.'})
    
    # POST 요청이 아닌 경우
    return JsonResponse({'status': 'failed', 'message': '잘못된 요청입니다.'})

@csrf_exempt
def get_led_status(request):
    if led.is_lit:
        return JsonResponse({'status': 'on', 'message': 'LED가 켜져 있습니다.'})
    else:
        return JsonResponse({'status': 'off', 'message': 'LED가 꺼져 있습니다.'})