function syncWordSample = makeSyncWord(samplingFreq)

% CW��Ψһ�ֵĳ���
cwPlusUwordLen = (2.56+0.48)/1000 * samplingFreq;
% CW��Ψһ������
s1 = -1 - 1i; s0 = -s1;
syncWord = [ones(1,64)*s0, [s0, s1, s1, s1, s1, s0, s0, s0, s1, s0, s0, s1] ];

%--- Find time constants --------------------------------------------------
ts = 1/samplingFreq;   
tc = 1/25000;  

codeValueIndex = ceil((ts * (0:cwPlusUwordLen-1)) / tc);
codeValueIndex(1) = 1;

syncWordSample = syncWord(codeValueIndex);
