tx README 
// 추가 예정 //
인풋 레지스터에서 sw98을 00하고 load버튼 누르면 리셋이었는데 mouth 에 reset 넣을 키가 부족해서 어차피 레지스터 리셋될때 같이 리셋 되도록. (인풋 레지스터에 외부출력 리셋 추가, 탑모듈에서 그거 이어주는 wire 추가
)



- tx 계획서
1. 설계목표
Simple Network Controller의 송신부 기능을 구현하되, 
데이터의 신뢰성을 확보하기 위해 CRC-8 생성 및 에러 검출 로직과 테스트 모드(특정 비트 인버젼)기능을 
설계 및 구현하였다. 
사용자가 스위치(SW)와 키(KEY)를 이용해 Destination ID, Source ID, Payload Length, Payload Data를 입력하면, 
이를 136비트 패킷으로 조립(Assembly)하고 미리 정해진 프레임 규격(Preamble, SFD, CRC-8 포함)에 맞춰 직렬(Serial)로 전송하는 것을 최종 목표로 한다.(preamble -> sfd -> dest_id -> src_id -> payload length -> payload -> crc-8)

2. 설계 규격
입력 :
-(Board 1&2) CLOCK_50: 50MHz 내부 시스템 클럭 
-(Board 1) KEY[0] (Load): 데이터 및 설정값 로드 (Falling Edge 동작) 
-(Board 1) KEY[1] (Tx Start): 패킷 전송 시작 (Trigger) 
-(Board 1) SW[9:8] (Mode Select): 동작 모드 설정 (00: Reset, 01: Header 설정, 10: Data 입력, 11: Test Mode) 
-(Board 1) SW[7:0] (Data): ID, Length, Payload 등의 데이터 입력 값

출력 :
-(Board 1) GPIO[1] (Tx Line): 직렬 데이터 출력 라인 
-(Board 1) LEDR[1:0] (Status): Header 설정 완료(LEDR1), Data 입력 완료(LEDR0) 표시 
-(Board 1) LEDR[3] (Busy): 데이터 전송 중임을 표시 
-(Board 1) HEX0, HEX1: 현재 입력 중인 데이터(SW[7:0]) 표시 
-(Board 1) HEX5: 현재 설정된 모드(SW[9:8]) 표시

3.설계 계획 
Tx Controller 설계

1) Block 설명

Assembler (tx_input_register) : 사용자의 입력을 받아 136비트의 tx_packet을 완성하는 모듈이다. Mode Select 방식을 도입하여 스위치 조작의 복잡성을 줄이고 직관성을 높였다. byte_ptr 레지스터를 사용하여 입력된 데이터를 패킷의 상위 비트부터 차례로 채워 넣는다.


Mouth (tx_transmitter) : 완성된 패킷을 프로토콜에 맞춰 전송한다. 내부 shift_reg에 데이터를 로드한 후, FSM 제어에 따라 MSB부터 1비트씩 쉬프트하며 tx_line으로 출력한다.


CRC8 Generator (crc8_serial) : 전송되는 데이터의 무결성을 보장하기 위해 추가된 모듈이다. 전송되는 비트열을 실시간으로 입력받아 CRC-8(다항식 0x07) 연산을 수행하며, 패킷의 마지막에 체크섬을 붙여 전송한다.

2) Block 주요 I/O 신호 
tx_packet [135:0]: Assembler에서 조립되어 Mouth로 전달되는 전체 데이터 패킷이다. Header와 Payload가 모두 포함된다.
(Header = dest_id + src_id + payload length)

tx_busy: 현재 전송이 진행 중인지(Mouth의 FSM이 IDLE이 아닌지)를 나타낸다. 전송 중에는 새로운 전송 명령이 무시되도록 제어하는 데 사용될 수 있다.

test_mode: 검증을 위해 추가된 신호로, 활성화 시 Mouth 모듈에서 특정 비트를(현재는 MSB) 강제로 반전(~shift_reg[127])시켜 출력한다. crc8_serial 에는 인버젼되지 않은 정상 비트를 보낼것이다. 그렇지 않으면 rx 입장에서는 payload(첫비트 반전된)에 대한 crc8(역시 첫비트 반전된)을 보고 오류인지 알 수 없기 떄문이다. 

(*** 주요 신호만 했는데 만약에 부족하시다면 gemini나 gpt 에 보고서 양식이랑 저희 v파일 모아놓은 폴더 첨부하면 잘 해줍니다!! ***)


3) 모듈 간 제어 구조 (FSM)

 송신 제어는 Mouth (tx_transmitter) 모듈 내의 FSM을 통해 이루어지며, 총 6단계의 상태를 가진다.

-S_IDLE: 대기 상태. tx_start 신호가 들어오면 패킷을 로드하고 tx_busy를 High로 올린 뒤 S_PREAMBLE로 이동 한다.
-S_PREAMBLE: 1010... 패턴을 16비트 전송하여 수신 측의 동기화를 돕는다.
-S_SFD: 10101011 (0xAB) 패턴 8비트를 전송하여 프레임의 시작을 알린다.
-S_HEADER: Assembler에서 설정한 Header 정보(ID, Length) 8비트를 전송한다.
-S_DATA: 실제 Payload 데이터를 전송한다. 이때 전송되는 비트는 CRC 모듈로도 동시에 입력된다. 설정된 Length만큼 전송이 끝나면 S_CRC로 천이한다.
-S_CRC: 계산된 8비트 CRC 값을 전송하고 S_IDLE로 복귀한다.

