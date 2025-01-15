% 使用symbol得到bit
% 输入为去掉64导码的symbol信号
function [bit_output] = from_symbol_get_bit(symbol_data)
    symbol_max_num = length(symbol_data);
    %按symbol解出bit
    old_symbol = 0;
    tmp_data = nan(1,2*symbol_max_num);
    tmp_symbol_data = symbol_data;
    for data_dex = 1:size(tmp_symbol_data,2)
        bits = mod(tmp_symbol_data(data_dex) - old_symbol,4);
        if(bits==0)
            tmp_data((data_dex-1)*2+1:data_dex*2) = [0,0];
        elseif(bits==1)
            tmp_data((data_dex-1)*2+1:data_dex*2) = [1,0];
        elseif(bits==2)
            tmp_data((data_dex-1)*2+1:data_dex*2) = [1,1];
        else
            tmp_data((data_dex-1)*2+1:data_dex*2) = [0,1];
        end
        old_symbol = tmp_symbol_data(data_dex);
    end
    bit_output = tmp_data;
end