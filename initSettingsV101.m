function settings = initSettingsV101()
% -------------------------------------------------------------------------
%                   SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%    @ Beijing Information Science and Technology University(BISTU)
%    2022. 08. 18
% -------------------------------------------------------------------------
%
%% Processing settings ==============================================
% Number of seconds to be processed 
settings.msToProcess          = (30-1)*60;        %[s]
% settings.msToProcess          = (5-1)*60;        %[s]
% Number of ship samples at the begining of the signal file 
settings.skipNumberOfMs       = 71067;
% Name of the TLE file to calculate SV position and velocity
settings.tleFile              = 'IRI0723.txt';
%% Base receiver related setting
% Base file
settings.IfFileBs = 'D:\铱星大作业数据\USRP_RX_326F3B5_V2.bin';     % 长基线的数据，6.77km基线
% Base start time of receiving UTC 2023-07-23 12:38:09
settings.LinuxStartTimeBs = 1690115889.2508507999999999849;     % [second] UTC 2023-07-23 12:38:09
[settings.startTimeBs,settings.startDoy] = LinuxTime2UTC(settings.LinuxStartTimeBs);
% Base receiver geo postion in LLA
settings.referRxPos       = [40.0364466666666667, 116.340006666666667, 53];  % [Degrees]

%% Rover receiver related setting
% Rover file
settings.IfFileRv = 'D:\铱星大作业数据\E3445\USRP_RX_E3445_V2.bin';
% Rover start time of receiving
settings.LinuxStartTimeRv = 1690115889.25069497499999998658;     % [second]   
[settings.startTimeRv,~]  = LinuxTime2UTC(settings.LinuxStartTimeRv);
% Rover receiver geo postion in LLA
settings.roverRxPos       = [40.0709594,  116.2745364, 81.445];   % [Degrees]


%% Raw signal file name and other parameter =========================
% Name of the EOP file
settings.eopFile              = 'EOP2_latest.txt';
% Data type used to store one sample
settings.dataType             = 'int16';  
% File Types
%1 - 8 bit real samples S0,S1,S2,...
%2 - 8 bit I/Q samples I0,Q0,I1,Q1,I2,Q2,...                      
settings.fileType             = 2;
% Intermediate, sampling and code frequencies
settings.IF                   = 0e6;              % [Hz]   1.364e6
settings.samplingFreq         =  2.5e6;              % [Hz]
% Iridium satellite visibility predict period
settings.visibT               = 90*48/1000;     % [s]  4.32s
% Elevation mask to exclude signals from satellites at low elevation
settings.elevationMask        = 0;           %[degrees 0 - 90]


%% Constants ========================================================
settings.c                 = 299792458;    % The speed of light, [m/s]
settings.f                 = 1626270833;   %信道7 AR（振铃警报）中心频率