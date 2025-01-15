function newSatdata = sortSatData(satdata,settings)

satList = unique([satdata.satID]);

svCnt = 1;
for index = 1: length(satList)
    svID = satList(index);
    svInd = find([satdata.satID] == svID);
    if length(svInd) == 1
        newSatdata(svCnt) = satdata(svInd);
    else
        doy = [satdata(svInd).doy];
        decimalDoy = (doy - floor(doy))*24*60;
        [~,Ind] = min(abs(decimalDoy - settings.startTime));
        newSatdata(svCnt) = satdata(svInd(Ind));
    end
    svCnt = svCnt + 1;
end
