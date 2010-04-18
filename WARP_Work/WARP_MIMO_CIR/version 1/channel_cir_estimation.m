% this function is to calculate the CI of the channel based on the
% correlation method
function CIR=channel_cir_estimation(RxData,number_of_transmitters,number_of_receivers)


% load the transmitted PN code
load -mat Sequences.GM;

index = 1;
CIR = cell(number_of_receivers*number_of_transmitters,1);
for m = 1 :  number_of_receivers
    for k = 1 : number_of_transmitters
        
        % correlate the received samples with the transmitted PN code
        CIR(index) = {xcorr(RxData(m,:),sequence{k})}; %#ok<USENS>
        index = index + 1;
    end
end

% modification for this function in the MIMO case is to calculate the
% correlation matrix instead of the correlation vector
% the file to be loaded has to be change to contain the code from each
% transmitter