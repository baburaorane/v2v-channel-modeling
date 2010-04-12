function CIR=channel_cir_estimation(RxData)

load '-mat' sequence.GM ;

CIR=xcorr(RxData,sequence,'none');