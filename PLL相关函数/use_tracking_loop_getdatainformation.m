%输入：
%         origin_data_with_preamble 带导码的数据信息
%         Frequent_estimate 初始的频率估计
%         Bn 环路带宽

%         settings 设置变量
%         dataindex 数据cw所在的index
%         cwPosEstimated 数据的cw所在的下标
% 输出：
%             time_after_pream 输出频率在cw后的时间
%             frequency_after_loop 使用环路的频率估计



function measOutput = use_tracking_loop_getdatainformation(origin_data_with_preamble,Frequent_estimate,Bn,settings,dataindex,cwPosEstimated,startTime)
%你认为不必要的输入可以删去，两个输出必须要保证







%   注意FLLLoop_get_frequency_with_lock函数的输出        
% time_after_pream对应你取出的多普勒的时间
% frequency_after_loop为你取出的多普勒


measOutput.time_after_pream=time_after_pream;
measOutput.FreqPLL=frequency_after_loop;


end