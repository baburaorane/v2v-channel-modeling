% this function is to calculate the CI of the channel based on the
% correlation method 
function CIR=channel_cir_estimation(RxData)


% load the transmitted PN code
load '-mat' sequence.GM ;

% correlate the received samples with the transmitted PN code 
CIR=xcorr(RxData,sequence,'none');

% modification for this function in the MIMO case is to calculate the
% correlation matrix instead of the correlation vector 
% the file to be loaded has to be change to contain the code from each
% transmitter