function visibleResults = getDopplerAtTime(ephemeris,RxPosEcef,settings,measureTime,VisibleSatList)



%--- Copy initial settings for all satellites -----------------------------
satCnt = length(VisibleSatList);
svCount = 1;
visibleResults.svIndex = nan (1,7);
visibleResults.satDoppler = nan(1,7);

if satCnt >= 1
    for svIndex = 1:satCnt
    [satPos, satVel] = getSatPosVel(measureTime,ephemeris(VisibleSatList(svIndex)),settings);

    %--- Find the elevation angel of the satellite ----------------
    [~, elevation, ~] = topocent(RxPosEcef, satPos - RxPosEcef');

    visibFlag = (elevation > settings.elevationMask);

    if visibFlag == 1
        tempDoppler = getSatDoppler(satPos,satVel,RxPosEcef,settings);
        visibleResults.svIndex(1,svCount) = VisibleSatList(svIndex);
        visibleResults.satDoppler(1,svCount) = tempDoppler;
        if svCount == 7
            break
        end
        svCount = svCount +1;
    end
    end
end


