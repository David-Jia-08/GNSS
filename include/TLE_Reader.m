function satdata = TLE_Reader(settings)
%File Description:TLE Files Reader

% Constant ----------------------------------------------------------------
ge = 398600.8; % Earth gravitational constant
TWOPI = 2*pi;
MINUTES_PER_DAY = 1440;
MINUTES_PER_DAY_SQUARED = (MINUTES_PER_DAY * MINUTES_PER_DAY);
MINUTES_PER_DAY_CUBED = (MINUTES_PER_DAY * MINUTES_PER_DAY_SQUARED);

fid = fopen(settings.tleFile);
line_0=fgetl(fid);
svIndex = 1;
while ischar(line_0)
    satID = str2double(line_0(9:11));              %Satellite ID
    % read first line
    tline = fgetl(fid);
    Cnum = tline(3:7);      			           % Catalog Number (NORAD)
    SC   = tline(8);					           % Security Classification
    ID   = tline(10:17);			               % Identification Number
    year = str2double(tline(19:20));               % Year
    doy  = str2double(tline(21:32));               % Day of year
    epoch = str2double(tline(19:32));              % Epoch
    TD1   = str2double(tline(34:43));              % first time derivative
    TD2   = str2double(tline(45:50));              % 2nd Time Derivative
    ExTD2 = tline(51:52);                          % Exponent of 2nd Time Derivative
    BStar = str2double(tline(54:59));              % Bstar/drag Term
    ExBStar = str2double(tline(60:61));            % Exponent of Bstar/drag Term
    BStar = BStar*1e-5*10^ExBStar;
    Etype = tline(63);                             % Ephemeris Type
%     Enum  = STR2DOUBLE(tline(65:end));           % Element Number
    
    % read second line
    tline = fgetl(fid);
    i = str2double(tline(9:16));                   % Orbit Inclination (degrees)
    raan = str2double(tline(18:25));               % Right Ascension of Ascending Node (degrees)
    e = str2double(strcat('0.',tline(27:33)));     % Eccentricity
    omega = str2double(tline(35:42));              % Argument of Perigee (degrees)
    M = str2double(tline(44:51));                  % Mean Anomaly (degrees)
    no = str2double(tline(53:63));                 % Mean Motion
    a = ( ge/(no*2*pi/86400)^2 )^(1/3);         % semi major axis (m)
    rNo = str2double(tline(65:end));               % Revolution Number at Epoch
    % Compact into a structure --------------------------------------------
    satdata(svIndex).satID = satID;
    satdata(svIndex).year = year;
    satdata(svIndex).doy   = doy;
    satdata(svIndex).epoch = epoch;
    satdata(svIndex).norad_number = Cnum;
    satdata(svIndex).bulletin_number = ID;
    satdata(svIndex).classification = SC; % almost always 'U'
    satdata(svIndex).revolution_number = rNo;
    satdata(svIndex).ephemeris_type = Etype;
    satdata(svIndex).xmo = M * (pi/180);
    satdata(svIndex).xnodeo = raan * (pi/180);
    satdata(svIndex).omegao = omega * (pi/180);
    satdata(svIndex).xincl = i * (pi/180);
    satdata(svIndex).eo = e;
    satdata(svIndex).xno = no * TWOPI / MINUTES_PER_DAY;
    satdata(svIndex).xndt2o = TD1 * 1e-8 * TWOPI / MINUTES_PER_DAY_SQUARED;
    satdata(svIndex).xndd6o = TD2 * TWOPI / MINUTES_PER_DAY_CUBED;
    satdata(svIndex).bstar = BStar;
    % Read the next SV TLE data -------------------------------------------
    line_0 = fgetl(fid);
    svIndex = svIndex + 1;
end
fclose(fid);

