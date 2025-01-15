% -------------------------------------------------------------------------
%                        LEO Satellite SOP Navigation
% Author:
%        Yafeng Li
%        @ Beijing Information Science and Technology University(BISTU)
% 2023. 06. 30
% -------------------------------------------------------------------------
%
%% Clean up and set the environment =======================================
clear; close all; clc;
format long g
disp(['   Signal generating started at ', datestr(now)]);

%--- Include folders with functions ---------------------------------------
addpath SGP4\                 % The software receiver functions
addpath include\
addpath tleFile
addpath PLL相关函数\


%% Initialize constants, settings and TLE =================================
settings = initSettingsV101();

% Read the TLE data for all satellites
ephemeris = TLE_Reader(settings);


% Remove the redundancy of TLE data for the same satellite ID
ephemeris = sortSatData(ephemeris,settings);

%% Generate plot of the IF data ===========================================
fprintf('Probing data (%s)...\n', settings.IfFileBs)
% %% Signal processing ====================================================== 
% baseMeas  = getMeasurementPLL(settings,'base');
% roverMeas = getMeasurementPLL(settings,'rover');

%% FOA positioning for rover receiver ============================

% True rover receiver position in ECEF
roverPos.Geo  = settings.roverRxPos;
roverPos.Ecef = geo2cartd(roverPos.Geo(1), roverPos.Geo(2), roverPos.Geo(3), 5);
VisibleSatList = getVisibleSat(ephemeris,roverPos.Ecef,settings,12*60+38);
% Biased position
biasedPosEcef = roverPos.Ecef+ [10000*randn, 10000*randn, 1000*randn];
% LSQ doppler positioning 
% % %利用偏移的初始位置biasedPosEcef定位
% 注意在定位时，要计算每个观测量来自哪一颗卫星，可以用遍历法将每个时刻的观测暴力搜索66颗卫星中的一个，保存其位置和速度
[position,velocity,ID] = getsatpvecef(VisibleSatList,ephemeris);%获得可见卫星的位置、速度
freq=zeros(length(ID));

for i=1:length(ID)%将卫星对应的代号、多普勒频移、位置、速度写入一个结构体中
    VisSatinfo(i,1).ID=ID(1,i);
    VisSatinfo(i,1).freq=freq(1,i);
    VisSatinfo(i,1).Pos=position(:,1,i);
    VisSatinfo(i,1).vel=velocity(:,1,i);
end
freq=dopler_sim(settings,VisSatinfo);
for i=1:length(ID)
    VisSatinfo(i,1).freq=freq(1,i);
end

estimatedPos1 = LeSq(VisSatinfo,biasedPosEcef,settings,freq');%最小二乘法确定接收机的位置

% Positioning error output
disp('【 ---------------- Rover FOA定位结果 ---------------- 】')
posErrorCalc(roverPos,estimatedPos1)
%% FDOA positioning for rover receiver ============================
% True rover receiver position in ECEF
roverPos.Geo  = settings.roverRxPos;
roverPos.Ecef = geo2cartd(roverPos.Geo(1), roverPos.Geo(2), roverPos.Geo(3), 5);
% Biased position
biasedPosEcef = roverPos.Ecef + [60000, 60000, 60000];
% LSQ doppler positioning 
% % % 多普勒差分定位
% Positioning error output
disp('【 ---------------- Rover FDOA定位结果 ---------------- 】')
posErrorCalc(roverPos,estimatedPos2)
%% TOA positioning for rover receiver ============================
% True rover receiver position in ECEF
roverPos.Geo  = settings.roverRxPos;
roverPos.Ecef = geo2cartd(roverPos.Geo(1), roverPos.Geo(2), roverPos.Geo(3), 5);
% Biased position
biasedPosEcef = roverPos.Ecef + [60000, 60000, 60000];
% LSQ doppler positioning 
% % %利用偏移的初始位置biasedPosEcef定位
% Positioning error output
disp('【 ---------------- Rover TOA定位结果 ---------------- 】')
posErrorCalc(roverPos,estimatedPos3)
%% TDOA positioning for rover receiver ============================


% True rover receiver position in ECEF
roverPos.Geo  = settings.roverRxPos;
roverPos.Ecef = geo2cartd(roverPos.Geo(1), roverPos.Geo(2), roverPos.Geo(3), 5);
% Biased position
biasedPosEcef = roverPos.Ecef + [60000, 60000, 60000];
% LSQ doppler positioning 
% % % 伪距差分定位
% Positioning error output
disp('【 ---------------- Rover TDOA定位结果 ---------------- 】')
posErrorCalc(roverPos,estimatedPos4)
%%
disp(['   Signal processing is over at', datestr(now)])
