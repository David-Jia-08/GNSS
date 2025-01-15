%% GPS L1 acquisition Demo
clc; clear; close all;
%------------------------------TLERead-------------------------------------%
startTime = datetime(2024,12,25,10,32,35);             
stopTime = datetime(2024,12,26);                       
sampleTime = 60;                                       % In seconds
sc = satelliteScenario(startTime,stopTime,sampleTime);
TLEfile='Iridium_NEXT.txt';%TLE文件名
SatData=tleread(TLEfile);%读取TLE文件
sat= satellite(sc,TLEfile);
time = datetime(2024,12,25,10,32,35);
[position,velocity] = states(sat,time,"CoordinateFrame","ecef");
%---------------------------ShowSat(Optional)------------------------------%
% show(sat)
% groundTrack(sat,LeadTime=3600)
% play(sc,PlaybackSpeedMultiplier=40)
%----------------------------Init_Setting----------------------------------%
settings=initSettings;
global point msbyte
point=settings.byteshift;
msbyte=0;
DATA=Readdata(settings);
len=size(DATA,1);
fs=30690000;
%------------------------------Acquire-------------------------------------%
gsa=gnssSignalAcquirer(GNSSSignalType="GPS C/A",SampleRate=fs);
[acqInfo,corVal]=gsa(DATA(1,:)',1:32);
%--------------------------------Plot--------------------------------------%
for i=1:4
    figure(i)
    freqRange= gsa.FrequencyRange;                                                   % Range of the frequency search in Hz
    stepSize = gsa.FrequencyResolution;                                              % Step size of frequency search in Hz
    satIndex = i;                                                                    % Visualize 1st satellite correlation
    mesh(freqRange(1):stepSize:freqRange(2),0:size(corVal,1)-1,corVal(:,:,satIndex)) % Surface plot
    xlabel("Doppler Offset")
    ylabel("Code Phase Offset")
    zlabel("Correlation")
    title("Correlation Plot for PRN ID: " + acqInfo.PRNID(satIndex))
end
%--------------------------------Tracking----------------------------------%
tr = zeros(len,1);
trinfo = struct("PhaseError",[],"PhaseEstimate",[],"FrequencyError",[],"FrequencyEstimate",[], ...
                "DelayError",[],"DelayEstimate",[]);  
for istep=1:len
    acqtable=gsa(DATA(istep,:)',22);
    if acqtable.IsDetected==1
    gst = gnssSignalTracker(GNSSSignalType="GPS C/A", ...
        SampleRate=fs,PRNID=acqtable.PRNID(acqtable.IsDetected), ...
        InitialCodePhaseOffset=acqtable.PRNID(acqtable.IsDetected), ...
        InitialFrequencyOffset=acqtable.FrequencyOffset(acqtable.IsDetected));
    % [trout,trinfo] = gst(DATA(1,:)')
    [tr(istep,:),trinfo(istep)] = gst(DATA(istep,:)');
    end
end
%--------------------------------Plot--------------------------------------%
scatterplot(tr(:))
%--------------------------Bit Synchronization-----------------------------%
% load trackedSignal.mat
trackedSignal = double(tr)/(2^6);
numCACodeBlocksPerBit = 20;
numAveragingBits = 100;
numAveragingSamples = numCACodeBlocksPerBit*numAveragingBits;
[maxTransitionLocation, transitionValues] = ...
    gnssBitSynchronize(imag(trackedSignal(1:numAveragingSamples,1)),numCACodeBlocksPerBit);
maxTransitionLocation;
bar(transitionValues)
xlabel('Sample Index')
ylabel('Number of Transitions')
title('Bit Transitions Chart')