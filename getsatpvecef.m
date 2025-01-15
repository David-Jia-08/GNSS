function [position,velocity,ID] = getsatpvecef(VisibleSatList,ephemeris,time)
Id=zeros(1,length(VisibleSatList));

for i=1:length(VisibleSatList)
    Id(1,i)=ephemeris(1,VisibleSatList(1,i)).satID;
    ID(1,i)="IRIDIUM "+Id(1,i);
end

startTime = datetime(2023,07,23,12,38,00);
stopTime = datetime(2023,07,23,12,39,00);
sampleTime = 1;                                       % In seconds
sc = satelliteScenario(startTime,stopTime,sampleTime);
TLEfile='IRI0723.txt';%TLE文件名
SatData=tleread(TLEfile);%读取TLE文件
sat= satellite(sc,TLEfile);
time = datetime(2023,07,23,12,38,09);%2023-07-23 12:38:09
k=1;

for j=1:length(SatData)
    for i=1:length(ID)
        if ID(1,i)==SatData(j,1).Name
            Index(1,k)=j;
            k=k+1;
        end
    end
end
[position,velocity] = states(sat(Index),time,"CoordinateFrame","ecef");
end

