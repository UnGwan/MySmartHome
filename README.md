# MySmartHome (Smart Circulator Control System)

## 프로젝트 소개

Smart Circulator Control System은 환경 및 사용자 기반 자동화를 목표로 설계된 스마트 서큘레이터 제어 시스템입니다. 이 프로젝트는 Raspberry Pi, Django, SwiftUI를 활용하여 집안의 서큘레이터를 원격으로 제어할 수 있는 기능을 제공합니다. 또한 온도, 습도, 체온을 기반으로 자동으로 최적의 바람 세기를 설정하거나, 사용자의 명령에 따라 다양한 모드를 실행할 수 있습니다.

## 주요 기능

### 1. 원격 제어

- iOS 앱을 통해 어디서든 서큘레이터를 제어할 수 있습니다.
- Raspberry Pi와 Django 서버를 이용해 신뢰성 높은 통신을 구현했습니다.

### 2. 환경 기반 자동화

- **온도 및 습도 데이터**: DHT-22 센서를 이용해 실시간으로 데이터를 측정하고, 최적의 바람 세기를 자동으로 설정합니다.
- **체온 측정 모드**: MLX90614 적외선 온도 센서를 사용하여 사용자의 체온을 감지하고, 이를 기반으로 서큘레이터 작동 여부를 제어합니다.

### 3. 사용자 편의성 향상

- **모드 설정**: 스마트 모드, 체온 측정 모드, 사용자 지정 모드 등 다양한 모드 제공.
- **실시간 데이터 시각화**: 온도와 습도 데이터를 실시간으로 그래프 형태로 표시.

## 기술 스택

- **하드웨어**: Raspberry Pi 4, MLX90614, DHT-22, IR 송수신기
- **백엔드**: Django
- **프론트엔드**: SwiftUI
- **기타**: lircd , Adafruit_DHT , smbus2

## 시스템 아키텍처

1. **Raspberry Pi**: 센서 데이터 수집 및 IR 송수신 제어.
2. **Django 서버**: 데이터를 처리하고 iOS 앱과 통신.
3. **iOS 앱**: 사용자 인터페이스 제공 및 명령 전송.

## 설치 및 실행 방법

### 1. Raspberry Pi 설정

- Python 패키지 설치:
  ```bash
  pip install django dht-sensor
  ```
- IR 송수신기 설정 (lircd 사용):
  ```bash
  sudo apt install lirc
  sudo systemctl enable lircd
  sudo systemctl start lircd
  ```
- DHT 센서 라이브러리 설치:
  ```bash
  pip install Adafruit_DHT
  ```
- MLX90614 드라이버 설치:
  ```bash
  pip install Adafruit-MLX90614 smbus2
  ```

### 2. Django 서버 실행

- 프로젝트 클론:
  ```bash
  git clone https://github.com/UnGwan/MySmartHome.git
  cd MySmartHome
  ```
- 서버 실행:
  ```bash
  python manage.py runserver
  ```

### 3. iOS 앱 실행

- Xcode에서 `MySmartHome` 프로젝트 열기.
- 실제 기기에 앱 배포.

## 향후 계획

- AI 기반 데이터 분석 및 제어 최적화.
- 사용자 입력 기반의 더 다양한 모드 추가.
- 실시간 데이터 시각화 기능 개선.


## 기록

1. [LED제어](https://velog.io/@jkj5666/SmartHome%EB%A7%8C%EB%93%A4%EA%B8%B0-1.-LED-%EC%A0%9C%EC%96%B4%ED%95%98%EA%B8%B0)<br>
2. [리모콘 신호 학습 및 전송](https://velog.io/@jkj5666/SmartHome%EB%A7%8C%EB%93%A4%EA%B8%B0-2.-%EB%A6%AC%EB%AA%A8%EC%BD%98-%EC%8B%A0%ED%98%B8-%EB%B3%B5%EC%A0%9C-%EB%B0%8F-%EC%A0%84%EC%86%A1-LIRC)
3. [서큘레이터 제어 ](https://velog.io/@jkj5666/SmartHome%EB%A7%8C%EB%93%A4%EA%B8%B0-%EC%84%9C%ED%81%98%EB%A0%88%EC%9D%B4%ED%84%B0-%EC%8A%A4%EB%A7%88%ED%8A%B8%ED%8F%B0%EC%9C%BC%EB%A1%9C-%EC%A0%9C%EC%96%B4%ED%95%98%EA%B8%B0)
4. [온/습도 모드 추가](https://velog.io/@jkj5666/SmartHome%EB%A7%8C%EB%93%A4%EA%B8%B0-%EC%9E%90%EC%B7%A8%EB%B0%A9-%EC%98%A8%EC%8A%B5%EB%8F%84%EC%97%90-%EB%94%B0%EB%9D%BC-%EC%84%9C%ED%81%98%EB%A0%88%EC%9D%B4%ED%84%B0-%EB%B0%94%EB%A0%98%EC%84%B8%EA%B8%B0-%EC%9E%90%EB%8F%99-%EC%A1%B0%EC%A0%95)
