function [ecefPos,ecefVel] = getSatPosVel(transmitTime,ephemeris,settings)
% -------------------------------------------------------------------------
%                  SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
%   Input:
%         transmitTime: time in minute 
%
%
global const
SAT_Const

year = ephemeris.year;
doy = ephemeris.doy;

% decimalDoy = doy - floor(doy);
% % amount of time in which you are going to propagate satellite's state 
% % vector forward (+) or backward (-) [minutes] 
% tsince = transmitTime - decimalDoy*24*60;  
DAY = settings.startDoy;
tsince = (DAY*24*60+transmitTime) - doy*24*60;
[rteme, vteme] = sgp4(tsince, ephemeris);

% This is used to accelerate the search process
persistent eopdata;
% eopdata=[];
if isempty(eopdata)
    % read Earth orientation parameters
    fid = fopen(settings.eopFile,'r');
    %  ----------------------------------------------------------------------------------------------------
    % |  Date    MJD      x         y       UT1-UTC      LOD       dPsi    dEpsilon     dX        dY    DAT
    % |(0h UTC)           "         "          s          s          "        "          "         "     s
    %  ----------------------------------------------------------------------------------------------------
    eopdata = fscanf(fid,'%i %d %d %i %f %f %f %f %f %f %f %f %i',[13 inf]);
    fclose(fid);
end


if (year < 57)
    year = year + 2000;
else
    year = year + 1900;
end

[mon,day,hr,minute,sec] = days2mdh(year,doy);
MJD_Epoch = mjuliandate(year,mon,day,hr,minute,sec);
MJD_UTC = MJD_Epoch+tsince/1440;

% Earth Orientation Parameters
[x_pole,y_pole,UT1_UTC,LOD,~,~,~,~,TAI_UTC] = IERS(eopdata,MJD_UTC,'l');
[~,~,~,TT_UTC,~] = timediff(UT1_UTC,TAI_UTC);
MJD_UT1 = MJD_UTC + UT1_UTC/86400;
MJD_TT  = MJD_UTC + TT_UTC/86400;
T = (MJD_TT-const.MJD_J2000)/36525;
[recef,vecef] = teme2ecef(rteme,vteme,T,MJD_UT1+2400000.5,LOD,x_pole,y_pole,0);

ecefPos = recef * 1000;
ecefVel = vecef * 1000;
