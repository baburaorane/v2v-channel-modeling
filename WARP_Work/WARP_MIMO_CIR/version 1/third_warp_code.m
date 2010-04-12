
clear all;clc;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0.0. Initializaton and definition of parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load some global definitions (packet types, etc.)
warplab_defines

% Create Socket handles and intialize nodes
[socketHandles, packetNum] = warplab_initialize;

%Separate the socket handles for easier access
% The first socket handle is always the magic SYNC
% The rest can be arranged in any combination of Tx and Rx
udp_Sync = socketHandles(1);
udp_Tx = socketHandles(2);
udp_RxA = socketHandles(3);


% Define the warplab options (parameters)
CaptOffset = 1000; %Number of noise samples per Rx capture. In [0:2^14]
TxLength = 2^14-1000; %Length of transmission. In [0:2^14-CaptOffset]
TransMode = 0; %Transmission mode. In [0:1] 
               % 0: Single Transmission 
               % 1: Continuous Transmission. Tx board will continue 
               % transmitting the vector of samples until the user manually
               % disables the transmitter. 
CarrierChannel = 6; % Channel in the 2.4 GHz band. In [1:14]
TxGainBB = 1; %Tx Baseband Gain. In [0:3]
TxGainRF = 5; %Tx RF Gain. In [0:63]
RxGainBB = 5; %Rx Baseband Gain. In [0:31]
RxGainRF = 1; %Rx RF Gain. In [1:3]

% Define the options vector; the order of options is set by the FPGA's code
% (C code)
optionsVector = [CaptOffset TxLength-1 TransMode CarrierChannel (RxGainBB + RxGainRF*2^16) (TxGainRF + TxGainBB*2^16)]; 
% Send options vector to the nodes
warplab_setOptions(socketHandles,optionsVector);

% Define the transmitted samples
t = 0:25e-9:(2^14-1)*25e-9;
TxData = exp(t*j*2*pi*1e6);

% Download the samples to be transmitted
warplab_writeSMWO(udp_Tx, TxData, RADIO2_TXDATA);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0.2. Prepare boards for transmission and reception and send trigger to 
% start transmission and reception (trigger is the SYNC packet)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enable transmitter radio path in transmitter node
warplab_sendCmd(udp_Tx, RADIO2_TXEN, packetNum);

% Enable receiver radio path in receiver node
warplab_sendCmd(udp_RxA, RADIO2_RXEN, packetNum);

% Prime transmitter state machine in transmitter node. Transmitter will be 
% waiting for the SYNC packet. Transmission will be triggered when the 
% transmitter node receives the SYNC packet.
warplab_sendCmd(udp_Tx, TX_START, packetNum);

% Prime receiver state machine in receiver node. Receiver will be waiting 
% for the SYNC packet. Capture will be triggered when the receiver 
% node receives the SYNC packet.
warplab_sendCmd(udp_RxA, RX_START, packetNum);

% Send the SYNC packet
warplab_sendSync(udp_Sync);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0.3. Read the received smaples from the Warp board
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read back the received samples
[RawRxData] = warplab_readSMRO(udp_RxA, RADIO2_RXDATA, TxLength+CaptOffset);
% Process the received samples to obtain meaningful data
[RxData,RxOTR] = warplab_processRawRxData(RawRxData);
% Read stored RSSI data
[RawRSSIData] = warplab_readSMRO(udp_RxA, RADIO2_RSSIDATA, (TxLength+CaptOffset)/8);
% Procecss Raw RSSI data to obtain meningful RSSI values
[RxRSSI] = warplab_processRawRSSIData(RawRSSIData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0.4. Reset and disable the boards
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset the receiver
warplab_sendCmd(udp_RxA, RX_DONEREADING, packetNum);

% Disable the receiver radio
warplab_sendCmd(udp_RxA, RADIO2_RXDIS, packetNum);

% Disable the transmitter radio
warplab_sendCmd(udp_Tx, RADIO2_TXDIS, packetNum);

% Close sockets
pnet('closeall');

figure;
plot(real(RxData));
grid on;xlabel('Rx I');

figure;
plot(imag(RxData));
grid on;xlabel('Rx Q');

freq_axis = 40e6*(0:2^14)/2^14;
freq_axis_shift = fftshift(freq_axis);
freq_ticks=[freq_axis_shift(1:2^13)-freq_axis_shift(2^13),freq_axis_shift(2^13+1:2^14+1)];

figure;
spectrum=10*log10(abs(fftshift(fft(TxData))));
plot(freq_ticks(2^12:3*2^12),spectrum(2^12:3*2^12));
grid on;xlabel('Tx Spectrum');

figure;
spectrum=10*log10(abs(fftshift(fft(RxData(CaptOffset:end),2^14))));
plot(freq_ticks(2^12:3*2^12),spectrum(2^12:3*2^12));
grid on;xlabel('Rx Spectrum');