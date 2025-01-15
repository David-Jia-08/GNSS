% 将Linux时间转换为当天UTC时的分钟与DOY值
function [startTime,doy] = LinuxTime2UTC(LinuxTime )
date = datestr(floor(LinuxTime)/86400 + datenum(1970,1,1),31);
year = str2num(date(1:4));
month = str2num(date(6:7));
day1 = str2num(date(9:10));
hour = str2num(date(12:13));
min = str2num(date(15:16));
second = str2num(date(18:19))+(LinuxTime-floor(LinuxTime));
startTime = hour*60 + min + second/60;
t=datetime(year,month,day1); 
doy=day(t,'dayofyear');
end