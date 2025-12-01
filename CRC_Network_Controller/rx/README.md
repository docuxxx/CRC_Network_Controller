rx README 
초본 완성 - 25_12_01




- rx 계획서

1. 설계목표
Simple Network Controller의 송신부 기능을 구현하되, 
데이터의 신뢰성을 확보하기 위해 CRC-8 생성 및 에러 검출 로직과 테스트 모드(특정 비트 인버젼)기능을 
설계 및 구현하였다. 
사용자가 스위치(SW)와 키(KEY)를 이용해 Destination ID, Source ID, Payload Length, Payload Data를 입력하면, 
이를 136비트 패킷으로 조립(Assembly)하고 미리 정해진 프레임 규격(Preamble, SFD, CRC-8 포함)에 맞춰 직렬(Serial)로 전송하는 것을 최종 목표로 한다.
(preamble -> sfd -> dest_id -> src_id -> payload length -> payload -> crc-8)

2. 설계 규격
입력 :
-(Board 1&2) CLOCK_50: 50MHz 내부 시스템 클럭 
-(Board 2) KEY[0] Negative edge Reset (Active Low)
-(Board 2) KEY[1] 미지정, 스페어 키
-(Board 2) SW[9:8] Rx ID
-(Board 2) SW[7:0] 미지정, 스페어 스위치

출력 :
-(Board 2) GPIO[1] (Tx Line): 직렬 데이터 출력 라인 
-(Board 2) LEDR[0] frame_valid - 정상 수신 여부 
-(Board 2) LEDR[1] crc_error - CRC 오류 발생 
-(Board 2) LEDR[2] Invalid__packet - 패킷 불일치 (ID 불일치) 
-(Board 2) LEDR[9:3] 미지정, 스페어 LEDR
-(Board 2) HEX0, HEX1 수신받은 Payload 1byte 출력
-(Board 2) HEX2 dest_id - 수신자 ID 
-(Board 2) HEX3 src_id - 송신자 ID
-(Board 2) HEX4,5 미지정, 스페어 display

3.설계 계획 
rx_receiver 설계

1) Block 설명

rx_receiver 모듈이 Rx (Top 모듈)에서 instantiation 되어 전달받은 데이터를 출력한다.
 
Tx와는 다르게 데이터를 입력하거나 Mode를 선택하는 경우가 없으므로 받은 데이터를 출력하고자하는 입출력장치(LEDR, 7-segment_display, KEY, SW 등)로 출력만 하면된다. 

Tx가 전송하고자하는 목표대로 정상 패킷이 전송됐다면 frame_valid가, CRC 체크 중 오류가 발생했다면 crc_error, 마지막으로 정상 프레임이 수신됐으나 rx가 처리할 수 없는 패킷일 때(dest_id 불일치) invalid_packet이 LEDR로 출력되어 발생한 frame_valid에서 확인하지 못한 패킷 오류가 있었음을 알 수 있다. 

고로, 위와 같은 출력들을 통해 통신 오류를 체크할 수 있을 것이다. 


Data Receiver (rx_receiver) : 
Tx로부터 송신된 Data를 rx_line으로 1비트씩 수신하고 처리하는 모듈. 각각의 _next (bit_shift) 레지스터들을 사용하여 1bit씩 들어오는 데이터들을 저장한다. 상태의 transition에 따라 처리하는 데이터가 달라지고, 처리된 데이터는 CRC error 체크 후 Rx (Top 모듈)에서 instantiation된 포트로 연결되어 출력된다. 
현재 비트 단위 shift 입력인데, counter를 사용하여 byte 단위마다 shift한다면 클럭 타이밍에 안전성을 확보할 수 있을 것으로 생각된다.


CRC8 Generator (crc8_serial) : 전송되는 데이터의 무결성을 보장하기 위해 추가된 모듈이다. 전송되는 비트열을 실시간으로 입력받아 CRC-8(다항식 0x07) 연산을 수행하며, 패킷의 마지막에 체크섬을 붙여 전송한다.

2) Block 주요 I/O 신호 
preamble_shift [15:0]: preamble 데이터를 1bit씩 shift해서 저장한다.
sfd_shift [7:0]: sfd 데이터를 1bit씩  shift해서 저장한다.
header [7:0]: tx_packet에서 송신된 header data를 수신 및 저장한다. 
payload [127:0]: tx_packet에서 header data를 제외한 data를 수신 및 저장한다.
crc_received [7:0]: crc8_serial에서 체크된 CRC 값을 받는다. 

frame_valid: 송신된 전체 packet이 다음 조건을 만족하여 정상적으로 수신되었음을 나타낸다.

조건  
1. PREAMBLE → SFD → HEADER → PAYLOAD → CRC 수신 절차가 모두 정상적으로 완료
2. 수신된 CRC(crc_received)와 수신 중 실시간 계산한 CRC(crc_computed)가 일치

crc_error: 수신된 CRC(crc_received)와 수신 중 실시간 계산한 CRC(crc_computed)가 일치하지 않을 때 1이되는 신호. 이 때 frame_valid는 0이 된다.

invalid_packet: 프레임 자체는 정상이나, 처리할 수 없는 packet일 때 1이된다.
ex) dest_id와 my_id가 다를 때 invalid_packet은 1이 된다.


3) 모듈 간 제어 구조 (FSM)

수신 제어는 rx_receiver 모듈 내 5개 상태 FSM으로 제어된다.
각각의 상태 동작 종료 후 다음 상태로 넘어가기 전 넘어갈 상태의 데이터를 미리 초기화 해준다.

WAIT_PREAMBLE: 대기 상태, preamble이 들어오는 순간 1비트씩 shift해서 detect. 
WAIT_SFD: SFD가 들어오는 순간 1비트씩 shift해서 detect (동작은 preamble과 동일)
HEADER: dest_id, src_id, payload_length가 순서대로 들어와 1byte를 구성하고, 이를 Header로 지칭.
Header 전체 크기인 1byte 수신 시 다음 상태로 transition
PAYLOAD: Payload는 가변길이이기 때문에 지정된 길이만큼 따로 Count 후, 전체 수신시 다음 상태로 transition
RECEIVED_CRC: crc8_serial 모듈이 수행한 crc 연산의 결과를 수신받는다.
전체 CRC 수신 완료시 결과에 따라 frame_valid, crc_error 출력

마지막 상태인 RECEIVED_CRC 내 연산 종료시 다음 프레임 입력 전 미리 초기화를 수행하여 WAIT_PREAMBLE로 transition 
