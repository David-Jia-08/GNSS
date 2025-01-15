function [lat,lon,alt] = XYZ2BLH(x,y,z)
% XECEF2GD  Performs the transformation from ECEF to geodetic
%           coordinates for a given position using WGS-84 constants.
%  pecef     ECEF position, with components in meters
%  lat      latitude of the position, in radians
%  lon      longitude of the position, in radians
%  alt      altitude of the position, in meters
%
pecef(1)=x;
pecef(2)=y;
pecef(3)=z;

g_asmaxis  = 6378137;
g_eccentr2 = 6.69437999014e-3;
e4 = g_eccentr2 * g_eccentr2;

a0 = - e4;
a1 = a0 + a0;
aa2 = g_asmaxis * g_asmaxis;
temp1 = 1. - g_eccentr2;
temp2 = g_eccentr2 / temp1;

%  Compute geodetic position

temp3 = pecef(1) * pecef(1) + pecef(2) * pecef(2);
b = temp3 / aa2;
c = pecef(3) * pecef(3) / aa2;
a4 = c * temp1;
a2 = b + a4 - e4;
a3 = a4 + a4;
q = temp2;
for kk = 1:5
  q = q - ((((a4*q+a3)*q+a2)*q+a1)*q+a0)/(((4.*a4*q+3.*a3)*q+2.*a2)*q+a1);
end
temp4 = 1. + q;
alt = (1. - q / temp2) * g_asmaxis * sqrt(c + b / (temp4 * temp4));
lat = atan2(temp4 * pecef(3) , sqrt(temp3));
lon = atan2(pecef(2) , pecef(1));
end 