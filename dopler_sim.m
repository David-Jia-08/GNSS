function doppler_shift=dopler_sim(settings,satinfo)
% 光速
c=settings.c; % m/s
% 输入：接收机ECEF位置 (单位: m)
receiver_ecef = [-2163652.22686998, 4382720.23065832, 4084070.52720215]; % 替换为接收机实际ECEF坐标
m=length(satinfo);
for i=1:m
sat_ecef_pos=satinfo(i).Pos';
sat_ecef_vel=satinfo(i).vel';
los_vector = receiver_ecef-sat_ecef_pos ;
% 归一化视线向量
los_unit = los_vector / norm(los_vector);
% 相对速度 (接收机速度假设为零，如有需要可调整)
relative_velocity = dot(sat_ecef_vel, los_unit); % m/s
% 信号频率 (例如 GPS)
f0 = settings.f; % Hz
% 多普勒频移
doppler_shift(1,i) = relative_velocity / c * f0+f0+1e2*randn;
% 显示结果
end
disp(['多普勒频移: ', num2str(doppler_shift-f0), ' Hz']);
end
