function measOutput = getMeasurementPLL(settings,station)

if (settings.fileType==1)
    dataAdaptCoeff=1;
else
    dataAdaptCoeff=2;
end

if strcmp(station, 'base')
    ifFile = settings.IfFileBs;
    startTime = settings.startTimeBs;
elseif strcmp(station, 'rover')
    ifFile = settings.IfFileRv;
    startTime = settings.startTimeRv;
end

[fid, ~] = fopen(ifFile, 'rb');

fftPointsCnt = 8192/2;

% Find number of samples per spreading code
samplesPerMS = round(settings.samplingFreq/1000);

% Move the starting point of processing. Can be used to start the
% signal processing at any point in the data record (e.g. for long
% records).
fseek(fid, settings.skipNumberOfMs * 2 * dataAdaptCoeff, 'bof');

% Signals of 4.32s
blockCnt = 90*48;     % [ms]

frameCnt = floor(settings.msToProcess*1000/blockCnt);

% read out the first ms data ---------------------------------------------
coef = fir1(50,40000/settings.samplingFreq);

% ---------------------------- Parameter initialization ------------------
% Length of signals to be processed
len5ms = settings.samplingFreq * 0.005;
len10ms = settings.samplingFreq * 0.01;
fftCnt = floor((blockCnt * samplesPerMS-len5ms-len10ms)/fftPointsCnt);
fftMem = zeros(1, fftCnt * fftPointsCnt);
fftMax = zeros(1,fftCnt);
% Length of CW and unique word
cwLen1 = 2.56 /1000 * settings.samplingFreq;
cwPlusUwordLen = (2.56+0.48)/1000 * settings.samplingFreq;
% Local samples of CW and unique word
syncWordSample = makeSyncWord(settings.samplingFreq);
ts = 1 / settings.samplingFreq;

% Measurement ------------
peakPerFrame = 7;
packedMeas.dataType = zeros(1, frameCnt * peakPerFrame);
packedMeas.satID = inf(1, frameCnt * peakPerFrame);
packedMeas.beamID = inf(1, frameCnt * peakPerFrame);
packedMeas.freqRefined = inf(1, frameCnt * peakPerFrame);
packedMeas.measureTime = zeros(1, frameCnt * peakPerFrame);
packedMeas.BeamTime = zeros(1, frameCnt * peakPerFrame);
packedMeas.validFlag   = zeros(1, frameCnt * peakPerFrame);

% ========================== Threshold setting ============================
cn0Th = 130;

%% ----------------------- Presessing the IF signals ----------------------
% Start waitbar
hwb = waitbar(0,'Tracking...');

meaureCnt = 1;
for index = 1: frameCnt
    % GUI update ----------------------------------------------------------
    % The GUI is updated every 2 times. This way Matlab GUI is still
    % responsive enough. At the same time Matlab is not occupied
    % all the time with GUI task.
    if (rem(index, 2) == 0)
        trackingStatus=['Precessing the ', int2str(index), ...
            'th epoch of ', int2str(frameCnt), ' ', station,' signal periods'];

        try
            waitbar(index/frameCnt,hwb,trackingStatus);
        catch
            % The progress bar was closed. It is used as a signal
            % to stop, "cancel" processing. Exit.
            disp('Progress bar closed, exiting...');
            return
        end
    end

    % Read 90*48ms of signal
    [data, count] = fread(fid, [1, dataAdaptCoeff * blockCnt * samplesPerMS], settings.dataType);

    if (count < dataAdaptCoeff * blockCnt * samplesPerMS)
        % The file is to short
        error('Could not read enough data from the data file.');
    end
    if (settings.fileType==2)
        data1 = data(1:2:end) + 1i .* data(2:2:end);
    end
    data1 = filter(coef,1,data1);

    % ======== Doopler frequency computation ==============================
    for fftInd = 1:fftCnt
        fftTemp = abs(fft(data1(fftPointsCnt*(fftInd-1)+1+len5ms:fftPointsCnt*fftInd+len5ms),fftPointsCnt));
        fftMax(fftInd) = max(fftTemp);
        fftMem(fftPointsCnt*(fftInd-1)+1:fftPointsCnt*fftInd) = fftTemp;
    end
    % FFT信噪比度量值
    fftmean = mean(fftMem);
    fftPeak = fftMax/fftmean;
    %用类信噪比的方式看信号大致出现的位置

    for ind = 1:peakPerFrame
        % 粗略位置检测
        [mValue,mPos] = max(fftPeak);
        if mValue < cn0Th
            break
        else
            % fftResult(ind) = mPos;
            mp1 = mPos- 8;    if mp1<=0, mp1 = 1; end
            mp2 = mPos + 8;  if mp2 >= fftCnt, mp2 = fftCnt; end
            fftPeak(mp1:mp2) = 0;

            % ------------- 粗略多普勒估计 -------------
            subSig1 = data1(fftPointsCnt*(mPos-1)+1+len5ms : fftPointsCnt*(mPos-1) +len10ms).^4;
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % 用subSig1的数粗估计信号的频率，将结果赋值为coarseFreq

            %%%%%%%%%%%%%%%%%%%%%%%%%%

            % ------------- CW头起始位置估计 -------------
            subSig2 = data1(fftPointsCnt*(mPos-2)+1+len5ms : fftPointsCnt*mPos +len5ms + cwPlusUwordLen);
            % ???
            phasePoints1 = (0 : (length(subSig2) -1)) * 2 * pi * ts;
            localCarr = exp(-1i * coarseFreq * phasePoints1);
            carrWiptOff = subSig2 .* localCarr;
            corrResult1 = xcorr(carrWiptOff,syncWordSample);
            corrResult2 = abs(corrResult1(end-length(carrWiptOff)+1:end));
            [~,mPos1] = max(corrResult2);
            cwPosEstimated = fftPointsCnt*(mPos-2)+1+len5ms + mPos1;
            % ------------- 估计精确的多普勒 -------------
            subSig3 = data1(cwPosEstimated: cwPosEstimated + cwLen1-1);
            eastimatedFreq = freqEstimate(subSig3,settings.samplingFreq);

            % Add tracking loop here --------------------------------------
            sigLen =(6.5) /1000 * settings.samplingFreq;
            sigWithPreamble = data1(cwPosEstimated: cwPosEstimated + sigLen-1);
            Bn = 50;
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            %写一下参数估计的函数
            %measOutput包括多普勒measOutput.FreqPLL和对应时间measOutput.time_after_pream
            %measOutput.time_after_pream参考一下第159行，对应的是其在CW之后多少秒
            measOutput = use_tracking_loop_getdatainformation(sigWithPreamble,eastimatedFreq,Bn,settings,index,cwPosEstimated,settings.startTimeRv);
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Pack the measurements --------------------------------------

            
            packedMeas.freqRefined(meaureCnt) = measOutput.FreqPLL;
            packedMeas.measureTime(meaureCnt) = startTime + ...
                (index-1)*4.32/60 + cwPosEstimated/settings.samplingFreq/60 + measOutput.time_after_pream/60;
            packedMeas.BeamTime(meaureCnt) = startTime + ...
                (index-1)*4.32/60 + cwPosEstimated/settings.samplingFreq/60;


            meaureCnt = meaureCnt +1;
            
        end % if mValue < cn0Th
    end  % for ind = 1:cntPerFrame
end % for index = 1: frameCnt


packedMeas.freqRefined = packedMeas.freqRefined(1:meaureCnt-1);
packedMeas.measureTime = packedMeas.measureTime(1:meaureCnt-1);
packedMeas.BeamTime    = packedMeas.BeamTime(1:meaureCnt-1);

measOutput = packedMeas;

close(hwb)