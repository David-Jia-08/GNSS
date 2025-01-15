function [AcqResult]= AcqL1(settings,DATA)
%------输入输出参数说明--------%
%AcqResult:捕获结果，结构体，五个成员变量。
%AcqResult.AcqedSatNum：捕获卫星数;
%AcqResult.PRN：捕获卫星的伪码编号列表;
%AcqResult.CodeDelay：捕获结果的码延时列表;
%AcqResult.Doppler：多普勒估计列表;
%AcqResult.CN0：载噪比估计列表;
%dataFile：数据文件，结构体，五个成员
%datafile.fs：采样率;
%IF=datafile.if：中频;
%datafile.name：文件路径;
%datafile.format：量化位数;
%datafile.byteshift：忽略开始的字节数;
%settings.acqsat:指定待捕卫星伪码编号；取值0-32整数；0，执行所有卫星遍历搜索；1-32，搜索指定卫星
%Nonnum:非相干累加次数
%------算法说明--------%
%基于IFFT的 m*Nnci 捕获算法
%--------------------data config--------------%
fs = settings.fs;%采样率
IF = settings.IF;%中频
ts = 1/fs;%
tc = 1/1.023e6;%L1码周期
blocksamples = fs/1000;
pfa = 0.001;%虚警率
dopplerrange = 10000;%多普勒范围+-10K
fstep = 500/settings.inttime;%多普勒分辨率500
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
L1=load('L1code.mat');%导入CA码序列
L1code=L1.code;
fprintf('C/A码加载完成。\n')
if (settings.acqsat==0)
    settings.acqsat = 1:32;
end
DATA=DATA(1,:);%对第一个1ms的信号进行搜索
data1=real(DATA);
data2=imag(DATA);%提取实部与虚部
for i= settings.acqsat
    prn=i;
    %---------------------------自己实现捕获------------------------------------%
    fprintf('正在搜索PRN %d...\n',i)
    %将C/A码上采样至fs
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

    % ---------------- 判断是否捕获成功 ----------------
    noiseFloor = mean(correlationResults(:));
    threshold = 13 * noiseFloor;  % 检测门限 (可调)
    if maxCorr > threshold
        fprintf('PRN %d 捕获成功！\n', prn);
        AcqResult.PRN = [AcqResult.PRN, prn];
        AcqResult.CodeDelay = [AcqResult.CodeDelay, codeDelay];
        AcqResult.Doppler = [AcqResult.Doppler, bestDoppler];
        AcqResult.CN0 = [AcqResult.CN0, 10*log10(maxCorr / noiseFloor)];
        % 绘制捕获结果
        % 绘制捕获结果的三维图
        figure;
        [X, Y] = meshgrid(1:blocksamples, dopplerBins);
        surf(X, Y, correlationResults, 'EdgeColor', 'none');
        colorbar;
        title(['PRN ', num2str(prn), ' 三维捕获结果']);
        xlabel('码延迟 (样本)');
        ylabel('多普勒频率 (Hz)');
        zlabel('相关峰值');
        view(30, 60); % 设置视角
        hold on;

        % 在三维图中标出最大峰值点
        plot3(codeDelay, bestDoppler, maxCorr, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
    else
        fprintf('PRN %d 未捕获。\n', prn);
    end
end

fprintf('GPS捕获完成。\n');
AcqResult.AcqedSatNum=length(AcqResult.PRN);

%--------------------------------------------------------------------------%
fprintf('AcqIfftL1 finished');


