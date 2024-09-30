from django.shortcuts import render

# views.py
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from gpiozero import LED

# GPIO 12번 핀에 연결된 LED 객체 생성
led = LED(12)

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