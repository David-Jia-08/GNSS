function VisibleSatList = getVisibleSat(ephemeris,RxPosEcef,settings,measureTime)
% -------------------------------------------------------------------------
%                  SoftSim: GPS IF signal simulator
% Author:
%        Yafeng Li
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%

% measureTime is in unit of min


SatList = nan(1,7);
%--- Copy initial settings for all satellites -----------------------------
satCnt = length([ephemeris.satID]);
svCount = 1;

for svIndex = 1:satCnt
    [satPos, ~] = getSatPosVel(measureTime,ephemeris(svIndex),settings);

    %--- Find the elevation angel of the satellite ----------------
    [~, elevation, ~] = topocent(RxPosEcef, satPos - RxPosEcef');

    visibFlag = (elevation > settings.elevationMask);

    if visibFlag == 1
        SatList(1,svCount) = svIndex;
        if svCount == 7
            break
        end
        svCount = svCount +1;
    end
end

VisibleSatList = SatList;
VisibleSatList(isnan(SatList)) = [];



