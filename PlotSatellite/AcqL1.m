function [AcqResult]= AcqL1(settings,DATA)
%------�����������˵��--------%
%AcqResult:���������ṹ�壬�����Ա������
%AcqResult.AcqedSatNum������������;
%AcqResult.PRN���������ǵ�α�����б�;
%AcqResult.CodeDelay��������������ʱ�б�;
%AcqResult.Doppler�������չ����б�;
%AcqResult.CN0������ȹ����б�;
%dataFile�������ļ����ṹ�壬�����Ա
%datafile.fs��������;
%IF=datafile.if����Ƶ;
%datafile.name���ļ�·��;
%datafile.format������λ��;
%datafile.byteshift�����Կ�ʼ���ֽ���;
%settings.acqsat:ָ����������α���ţ�ȡֵ0-32������0��ִ���������Ǳ���������1-32������ָ������
%Nonnum:������ۼӴ���
%------�㷨˵��--------%
%����IFFT�� m*Nnci �����㷨
%--------------------data config--------------%
fs = settings.fs;%������
IF = settings.IF;%��Ƶ
ts = 1/fs;%
tc = 1/1.023e6;%L1������
blocksamples = fs/1000;
pfa = 0.001;%�龯��
dopplerrange = 10000;%�����շ�Χ+-10K
fstep = 500/settings.inttime;%�����շֱ���500
fnum = dopplerrange/fstep;
dopplerBins=-dopplerrange:fstep:dopplerrange;
%--------------------------------------------------------------------------%
AcqResult.AcqedSatNum=0;
AcqResult.PRN=[];
AcqResult.CodeDelay=[];
AcqResult.Doppler=[];
AcqResult.CN0=[];
AcqResult.phi=[];
%--------------------------------------------------------------------------%
L1=load('L1code.mat');%����CA������
L1code=L1.code;
fprintf('C/A�������ɡ�\n')
if (settings.acqsat==0)
    settings.acqsat = 1:32;
end
DATA=DATA(1,:);%�Ե�һ��1ms���źŽ�������
data1=real(DATA);
data2=imag(DATA);%��ȡʵ�����鲿
for i= settings.acqsat
    prn=i;
    %---------------------------�Լ�ʵ�ֲ���------------------------------------%
    fprintf('��������PRN %d...\n',i)
    %��C/A���ϲ�����fs
    cacode=L1code(i,:);
    cacodeupsampled=repelem(cacode,fs*tc);
    cacode1ms=cacodeupsampled(1:blocksamples);
    caCodeFreq = conj(fft(cacode1ms));
    correlationResults = zeros(length(dopplerBins),blocksamples);
    for dopplerIdx = 1:length(dopplerBins)
        doppler = dopplerBins(dopplerIdx);
        t = (0:blocksamples-1) / fs;
        dopplerSignal = exp(-1j * 2 * pi * (IF + doppler) .* t);
        signal1 = data1 .* dopplerSignal;
        signal2 = data2 .* dopplerSignal;
        signal1Freq = fft(signal1);
        signal2Freq = fft(signal2);
        correlation1 = abs(ifft(signal1Freq .* caCodeFreq)).^2;
        correlation2 = abs(ifft(signal2Freq .* caCodeFreq)).^2;
        correlationResults(dopplerIdx, :) = correlation1 + correlation2;
    end
    [maxCorr, idx] = max(correlationResults(:));
    [bestDopplerIdx, codeDelay] = ind2sub(size(correlationResults), idx);
    bestDoppler = dopplerBins(bestDopplerIdx);

    % ---------------- �ж��Ƿ񲶻�ɹ� ----------------
    noiseFloor = mean(correlationResults(:));
    threshold = 13 * noiseFloor;  % ������� (�ɵ�)
    if maxCorr > threshold
        fprintf('PRN %d ����ɹ���\n', prn);
        AcqResult.PRN = [AcqResult.PRN, prn];
        AcqResult.CodeDelay = [AcqResult.CodeDelay, codeDelay];
        AcqResult.Doppler = [AcqResult.Doppler, bestDoppler];
        AcqResult.CN0 = [AcqResult.CN0, 10*log10(maxCorr / noiseFloor)];
        % ���Ʋ�����
        % ���Ʋ���������άͼ
        figure;
        [X, Y] = meshgrid(1:blocksamples, dopplerBins);
        surf(X, Y, correlationResults, 'EdgeColor', 'none');
        colorbar;
        title(['PRN ', num2str(prn), ' ��ά������']);
        xlabel('���ӳ� (����)');
        ylabel('������Ƶ�� (Hz)');
        zlabel('��ط�ֵ');
        view(30, 60); % �����ӽ�
        hold on;

        % ����άͼ�б������ֵ��
        plot3(codeDelay, bestDoppler, maxCorr, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
    else
        fprintf('PRN %d δ����\n', prn);
    end
end

fprintf('GPS������ɡ�\n');
AcqResult.AcqedSatNum=length(AcqResult.PRN);

%--------------------------------------------------------------------------%
fprintf('AcqIfftL1 finished');


