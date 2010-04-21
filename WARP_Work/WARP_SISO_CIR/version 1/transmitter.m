% code for the transmitter 
% it will run in continious mode with infinite pause interval

clear all;clc;close all;

% the pause interval to allow for continious transmission 
receiver_interval=inf;

% polynomial to generate the PN code
polynomial_order=9;
polynomial=[9 4 0];

%Load some global definitions (packet types, etc.)
warplab_defines

% Create Socket handles and intialize nodes
[socketHandles, packetNum] = warplab_initialize(1);

%Separate the socket handles for easier access
% The first socket handle is always the magic SYNC
% the second socket handle is handle for the connected kit (Tx kit)
udp_Sync = socketHandles(1);
udp_Tx = socketHandles(2);


% Define the warplab options (parameters)
CaptOffset = 1000;    %Number of noise samples per Rx capture. In [0:2^14]
TxLength = 2^14-1000; %Length of transmission. In [0:2^14-CaptOffset]
TransMode = 1; %Transmission mode. In [0:1] 
               % 0: Single Transmission 
               % 1: Continuous Transmission. Tx board will continue 
               % transmitting the vector of samples until the user manually
               % disables the transmitter. 
CarrierChannel = 11;   % Channel in the 2.4 GHz band. In [1:14]
TxGainBB = 3;         %Tx Baseband Gain. In [0:3]
TxGainRF = 40;         %Tx RF Gain. In [0:63]

% Define the options vector; the order of options is set by the FPGA's code
% (C code)
optionsVector = [CaptOffset TxLength-1 TransMode CarrierChannel ...
                 (TxGainBB + TxGainRF*2^16) (TxGainRF + TxGainBB*2^16)]; 
% Send options vector to the nodes
warplab_setOptions(socketHandles,optionsVector);

%Define transmitted samples
TxData = generate_transmitted_data(TxLength,polynomial_order,polynomial);

% Download the samples to be transmitted to the transmitter kit
warplab_writeSMWO(udp_Tx, TxData, RADIO2_TXDATA);


% Prepare boards for transmission send trigger to 
% start transmission(trigger is the SYNC packet)

% Enable transmitter radio path in transmitter node
warplab_sendCmd(udp_Tx, RADIO2_TXEN, packetNum);


% Prime transmitter state machine in transmitter node. Transmitter will be 
% waiting for the SYNC packet. Transmission will be triggered when the 
% transmitter node receives the SYNC packet.
warplab_sendCmd(udp_Tx, TX_START, packetNum);

% Send the SYNC packet
warplab_sendSync(udp_Sync);

pause(receiver_interval);

% Disable the transmitter radio
warplab_sendCmd(udp_Tx, RADIO2_TXDIS, packetNum);

% Close sockets
pnet('closeall');

