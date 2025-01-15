  clc; clear; close all;
%------------------------------TLERead-------------------------------------%
startTime = datetime(2023,07,23,12,38,00);             
stopTime = datetime(2023,07,26);                       
sampleTime = 60;                                       % In seconds
sc = satelliteScenario(startTime,stopTime,sampleTime);
TLEfile='IRI0723.txt';%TLE文件名
SatData=tleread(TLEfile);%读取TLE文件
sat= satellite(sc,TLEfile);
time = datetime(2023,07,23,12,38,09);%2023-07-23 20:38:09
[position,velocity] = states(sat,time,"CoordinateFrame","ecef");
%---------------------------ShowSat(Optional)------------------------------%
 show(sat)
 groundTrack(sat,LeadTime=36)
 play(sc,PlaybackSpeedMultiplier=40)
