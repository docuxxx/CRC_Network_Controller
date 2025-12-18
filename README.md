2025 하반기 디지털시스템설계 텀프로젝트 주제로, CRC 오류 체크 알고리즘 기반의 Network Controller 설계를 목표로 한다. 



2025-12-17

16bit clock_divide register 구현에서 최소 크기 5bit register로 축소 및 cost 최소화
이에따른 보드 동작 성공

Testbench clock 신호 clock_divide로 수정 완료

최종 구현 완료 및 최적화 완료.




2025-12-15 
최종 보드 Test 중 clock divide 필요성 확인

Counter를 활용한 clock 신호 분주로 clock 속도 낮춤. 

보드 동작 성공, 이후 최소 크기 register 사용으로 구현 필요. 

Testbench 수정 동시 작업. 





2025-12-14

Tx-Rx testbench 작성 중 (13시 ~)

Test case 

Test용 DUT는 시작 버튼이 따로 존재x 
Tx_line 자체가 Rx_line과 연결되기에 항상 데이터를 전송하고 있는 상태

1. Normal mode 1byte 전송
2. Test mode ㅡMSB Inversion (1Byte)
3. My_id, Dest_id inccorrect -> invalid packet case
위 case로 Test 예정.

Testbench 작성 완료 (02시)

Test case 
1. Normal mode 1byte 전송
2. Test mode ㅡMSB Inversion (1Byte) 
3. My_id, Dest_id inccorrect -> invalid packet case\
   
위 case로 Test 성공 
Ideal한 상태이므로 보드 동작과 다를 수 있음을 유의. 



2025-12-11

최종 구현 성공 (보드 클럭 동작 및 tx - nextshift 형태로 수정)
cost 최소화를 위한 리팩토링 필요 



2025-12-07
수정 내용 :

0. Test Mode 시, Tx에서 전송한 Data의 CRC-8 값이 Rx의 HEX로 표현되는 오류 발생 --> tx_line code가 bit delay 유발 확인, 수정 후 해결 완료




2025-12-04
Term Project 진행 상황

0. Tx payload register 저장 시, LEDR 반응 X --> byte_ptr과 target_length 조건문 수정 후, 해결 완료

1. Tx CRC-8 계산 시 오류 발생 --> next_register 사용하여 최신 bit의 타이밍을 맞춰서 해결 완료

2. Tx에서 bitstream 전송 시, reset 안됨 --> reset code 추가하여 해결 완료

3. Tx ~ Rx bitstream 송신 시, timing 오류 발생 --> Tx 내부 CLK_50M를 GPIO pin을 사용하여 Rx로 공유(CLK sync 맞춤)



오전 3:03 2025-12-01
금일 회의 내용 : 역할 분담 및 rx 설계 예정
0. rx 초본 완성 - 김준기

1. 추후 serial bit form은 유지하되, bit_cnt == 7일 때(1byte)일 때만 shift하도록 수정 가능 
   해당 로직으로 수정했을 때 기대효과 -> 1bit씩 shift했을 때보다 클럭 타이밍 여유 생김 


오전 2:49 2025-11-30
수정 내용 : 

2025 주제 단방향 통신 controller 수정으로 인한 전체 코드 수정 중

2025-11-30 회의 예정

0. rx/tx 폴더 구분 및 코드 커밋
  
1. 이전 코드 유지 및 백업 

2. CRC logic 리팩토링 - 최선우

3. tx 모듈 완성 - 최선우  


오전 3:05 2025-11-29
수정 내용 : 

0. Test mode에서 특정 비트 인버젼 후 CRC detect 시 송수신은 인버젼된 data로, CRC는 원본 data로 연산 수행하도록 수정

1. CRC 에러 detect시 재입력 기능 추가에 대해

if) 메인 컨트롤러 모듈에서 루프백 받으면 데이터가 잘 전송됐다는 뜻이니까,  루프백 플래그(rx_valid)가 0일 때 (데이터 전송 실패) 일정 시간 기다렸다가 다시 데이터 입력받도록 하는 기능 추가로 해결 가능할 것으로 생각.
rx_valid가 0이 되는 상황은 CRC detect 됐을 때랑 data format 깨졌을 때, 물리적으로 연결 끊겼을 때 정도. - 루프백 기능 사용 x

2. 데이터 저장 가변 길이 문제
case문으로 길이 지정해두고 fsm으로 길이 지정.

3. CRC 알고리즘

모듈 내 구현된 CRC 알고리즘은 교안 속 8비트 동시 계산 방식이 아니라, 1비트씩 계산하는 형태이고
쉽게 생각하면 binary convolution sum을 슬라이딩 윈도우해서 하는 거랑 같은 방식.

