% code for the receiver
clear all;clc;close all;

%Load some global definitions (packet types, etc.)
warplab_defines

load '-mat' CycleSize.GM;


% Create Socket handles and intialize nodes
[socketHandles, packetNum] = warplab_initialize(1);

%Separate the socket handles for easier access
% The first socket handle is always the magic SYNC
% the second socket handle is handle for the connected kit (Rx kit)
udp_Sync = socketHandles(1);
udp_RxA = socketHandles(2);


% Define the warplab options (parameters)
CaptOffset = 0;              %Number of noise samples per Rx capture. In [0:2^14]
TxLength = 2^14-CaptOffset;  %Length of transmission. In [0:2^14-CaptOffset]
TransMode = 1;               %Transmission mode. In [0:1]
% 0: Single Transmission
% 1: Continuous Transmission. Tx board will continue
% transmitting the vector of samples until the user manually
% disables the transmitter.


CarrierChannel = 6;     % Channel in the 2.4 GHz band. In [1:14]
RxGainBB_2 = 15;        % Rx Baseband Gain. In [0:31]
RxGainRF_2 = 1;         % Rx RF Gain. In [1:3]
RxGainBB_3 = 15;        % Rx Baseband Gain. In [0:31]
RxGainRF_3 = 1;         % Rx RF Gain. In [1:3]
number_of_trials = 2;
TxSelect = 2;           % 2 means that we will use the 2 antennas
RxSelect = 2;           % 2 means that we will use the 2 antennas

% Define the options vector; the order of options is set by the FPGA's code
% (C code)
optionsVector = [CaptOffset TxLength-1 TransMode CarrierChannel ...
    (RxGainBB_2 + RxGainRF_2*(2^16)) ...
    (RxGainRF_2 + RxGainBB_2*(2^16)) ...
    (RxGainBB_2 + RxGainRF_2*(2^16)) ...
    (RxGainRF_2 + RxGainBB_2*(2^16))  TxSelect RxSelect];

% Send options vector to the nodes
warplab_setOptions(socketHandles,optionsVector);


% Read back the received samples
for k = 1:number_of_trials
    
    tic
    % Prepare boards for transmission and reception and send trigger to
    % start reception (trigger is the SYNC packet)
    
    % Enable receiver radio path in receiver node
    warplab_sendCmd(udp_RxA, RADIO2_RXEN, packetNum);
    warplab_sendCmd(udp_RxA, RADIO3_RXEN, packetNum);
    
    % Prime receiver state machine in receiver node. Receiver will be waiting
    % for the SYNC packet. Capture will be triggered when the receiver
    % node receives the SYNC packet.
    warplab_sendCmd(udp_RxA, RX_START, packetNum);
    
    % Send the SYNC packet
    warplab_sendSync(udp_Sync);
    
    % Read the received smaples from the Warp board
    RawRxData1 = warplab_readSMRO(udp_RxA, RADIO2_RXDATA,TxLength);
    RawRxData2 = warplab_readSMRO(udp_RxA, RADIO3_RXDATA, TxLength);
    toc
    
    % Process the received samples to obtain meaningful data
    [RxData(1,:),RxOTR1] = warplab_processRawRxData(RawRxData1);
    [RxData(2,:),RxOTR2] = warplab_processRawRxData(RawRxData2);
    
    % Reset and disable the boards
    
    % Reset the receiver
    warplab_sendCmd(udp_RxA, RX_DONEREADING, packetNum);
    
    % calculate the Channel Impulse Response(CIR)
    CIR = channel_cir_estimation(RxData,2,2);
    
    for m = 1 : length(CIR)
        figure;
        plot(abs(CIR{m}));
        grid on;xlabel('n');ylabel('|h(n)|');
        title('Channel Impulse Response-magnitude');
    end
    
    figure;
    plot(real(RxData(1,:)));
    grid on;xlabel('Rx I');
    
    figure;
    plot(real(RxData(2,:)));
    grid on;xlabel('Rx Q');
    
    % Disable the receiver radio
    warplab_sendCmd(udp_RxA, RADIO2_RXDIS, packetNum);
    warplab_sendCmd(udp_RxA, RADIO3_RXDIS, packetNum);
    
end

% Close sockets
pnet('closeall');
