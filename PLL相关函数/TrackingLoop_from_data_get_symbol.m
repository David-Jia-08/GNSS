%本函数用于使用tracking方法，通过带64个导码的数据和初始的频率估计得到可用的symbol结果
% 
% 输入：
%     origin_data_with_preamble       带导码的数据
%     Frequent_estimate               该数据的多普勒估计
%     settings                        设置变量
% 输出：
%     tmp_bit_data                    symbol数组
%     error_deg                       求解symbol时与标准角度的差值
%     max_delta_degree                鉴相器输出的最大误差角，用于观察环路性能
%     mean_delta_degree               鉴相器输出的均值，用于观察环路性能
%     std_delta_degree                鉴相器输出的标准差，用于观察环路性能
%     CN0                             用156个symbol计算的CN0


%%
function [tmp_symbol_data,error_deg,P_lock,F_lock,CN0] = TrackingLoop_from_data_get_symbol(origin_data_with_preamble,Frequent_estimate,settings,lock_time,Bn)
%在定义函数的时候，可以除去不用的（输入或输出）量，保证程序可运行即可
    



       

end