function posErrorCalc(refPos,rxPosECEF)

%% Position of the reference ==============================================
% refPos.Ecef
% refPos.Geo
% refPos.ENU
refPos.utmZone = findUtmZone(refPos.Geo(1), refPos.Geo(2));      
% Position in ENU
[refPos.ENU(1),refPos.ENU(2),refPos.ENU(3)] = ...
     cart2utm(refPos.Ecef(1),refPos.Ecef(2),refPos.Ecef(3),refPos.utmZone);

%% Position of the receiver ===============================================
% rxPos.Ecef
% rxPos.Geo
% rxPos.ENU
rxPos.Ecef = rxPosECEF';
[rxPos.Geo(1), rxPos.Geo(2), rxPos.Geo(3)] = ...
                    cart2geo(rxPos.Ecef(1),rxPos.Ecef(2),rxPos.Ecef(3), 5);
% Convert to UTM coordinate system
rxPos.utmZone = findUtmZone(rxPos.Geo(1), rxPos.Geo(2));      
% Position in ENU
[rxPos.ENU(1),rxPos.ENU(2),rxPos.ENU(3)] = ...
     cart2utm(rxPos.Ecef(1),rxPos.Ecef(2),rxPos.Ecef(3),rxPos.utmZone);

%% Display output =========================================================
disp( '参考点的位置坐标为：')
disp(['    【ECEF系中 x y z 坐标：',num2str(refPos.Ecef),'米 】'])
% disp(['    【UTM系中 E N U 坐标：',num2str(refPos.ENU),'米 】'])

disp( 'LEO定位结果为：')
disp(['    【ECEF系中 x y z 坐标：',num2str(rxPos.Ecef),'米 】'])
% disp(['    【UTM系中 E N U 坐标：',num2str(rxPos.ENU),'米 】'])

disp( 'LEO定位误差为：')
disp(['    【ECEF系中 x y z 误差：',num2str(rxPos.Ecef - refPos.Ecef),'米 】'])
disp(['    【 UTM系中 E N U 误差：',num2str(rxPos.ENU - refPos.ENU),'米 】'])
disp(['    【三维总误差：',num2str(norm(rxPos.Ecef - refPos.Ecef)),'米 】'])
disp('   ')

