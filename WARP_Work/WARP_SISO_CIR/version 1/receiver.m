% code for the receiver
clear all;clc;close all;

%Load some global definitions (packet types, etc.)
warplab_defines

% Create Socket handles and intialize nodes
[socketHandles, packetNum] = warplab_initialize(1);

%Separate the socket handles for easier access
% The first socket handle is always the magic SYNC
% the second socket handle is handle for the connected kit (Rx kit)
udp_Sync = socketHandles(1);
udp_RxA = socketHandles(2);


% Define the warplab options (parameters)
CaptOffset = 1000;    %Number of noise samples per Rx capture. In [0:2^14]
TxLength = 2^14-1000; %Length of transmission. In [0:2^14-CaptOffset]
TransMode = 1; %Transmission mode. In [0:1] 
               % 0: Single Transmission 
               % 1: Continuous Transmission. Tx board will continue 
               % transmitting the vector of samples until the user manually
               % disables the transmitter. 
CarrierChannel = 11;   % Channel in the 2.4 GHz band. In [1:14]
RxGainBB = 20;         %Rx Baseband Gain. In [0:31]
RxGainRF = 1;         %Rx RF Gain. In [1:3]

% Define the options vector; the order of options is set by the FPGA's code
% (C code)
optionsVector = [CaptOffset TxLength-1 TransMode CarrierChannel ...
                 (RxGainBB + RxGainRF*2^16)]; 
% Send options vector to the nodes
warplab_setOptions(socketHandles,optionsVector);


% Prepare boards for transmission and reception and send trigger to 
% start reception (trigger is the SYNC packet)

% Enable receiver radio path in receiver node
warplab_sendCmd(udp_RxA, RADIO2_RXEN, packetNum);


% Prime receiver state machine in receiver node. Receiver will be waiting 
% for the SYNC packet. Capture will be triggered when the receiver 
% node receives the SYNC packet.
warplab_sendCmd(udp_RxA, RX_START, packetNum);

% Send the SYNC packet
warplab_sendSync(udp_Sync);

% Read the received smaples from the Warp board

% Read back the received samples
[RawRxData] = warplab_readSMRO(udp_RxA, RADIO2_RXDATA, TxLength+CaptOffset);
% Process the received samples to obtain meaningful data
[RxData,RxOTR] = warplab_processRawRxData(RawRxData);
% Read stored RSSI data
[RawRSSIData] = warplab_readSMRO(udp_RxA, RADIO2_RSSIDATA, (TxLength+CaptOffset)/8);
% Procecss Raw RSSI data to obtain meningful RSSI values
[RxRSSI] = warplab_processRawRSSIData(RawRSSIData);

% Reset and disable the boards

% Reset the receiver
warplab_sendCmd(udp_RxA, RX_DONEREADING, packetNum);

% Disable the receiver radio
warplab_sendCmd(udp_RxA, RADIO2_RXDIS, packetNum);

% Close sockets
pnet('closeall');

% calculate the Channel Impulse Response(CIR)
CIR=channel_cir_estimation(RxData);

figure;
plot(abs(CIR));
grid on;xlabel('n');ylabel('|h(n)|');
title('Channel Impulse Response-magnitude');

figure;
plot(wrapToPi(angle(CIR)));
grid on;xlabel('n');ylabel('<h(n)');
title('Channel Impulse Response-phase');


figure;
plot(real(RxData));
grid on;xlabel('Rx I');

figure;
plot(imag(RxData));
grid on;xlabel('Rx Q');

