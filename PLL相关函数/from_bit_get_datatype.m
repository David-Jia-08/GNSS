% 使用bit数据判断信号的类型
% 输入为去掉64导码的symbol信号得到的bit
% 输出：
%         -1【没有该类型】
%          1【BC】
%          2【RA】
function [data_type] = from_bit_get_datatype(bit_input)
    %置错
    data_type = -1;


%% 第一步，按python 96
    %将数据变成偶数,由于是按symbol1：2生成的，一般是没有问题的
    data_1 = bit_input(1: (length(bit_input)-mod(length(bit_input),2)));
    %按line98 进行倒置
    data_reverse = nan(1,length(data_1));
    
    for reverse = 1:2:length(data_1)-1
        data_reverse(reverse) = data_1(reverse+1);
        data_reverse(reverse+1) = data_1(reverse);
    end

    %% 验证是否为BC信号
    %去除导码
    data_reverse_d_uw = data_reverse(25:length(data_reverse));

    hdrlen=6;
    blocklen=64;
    hdr_poly = 29;
    ringalert_bch_poly=1207;
    
    if(length(data_reverse_d_uw) > (hdrlen+blocklen))
        if(ndivide(hdr_poly,data_reverse_d_uw(1:hdrlen))==0)
            %取出有用的比特
            tmp_data_for_IBC = data_reverse_d_uw(hdrlen+1:hdrlen+blocklen);
            %分成两组

            o_bc1 = nan(1,32);
            o_bc2 = nan(1,32);

            cal_type1_bc = 1;%type1计数器
            for type1_bc = length(tmp_data_for_IBC)-1:-2:1
                cal_result = mod(cal_type1_bc,2);
                dex_result = floor( (cal_type1_bc-1) /2 ) + 1;%判断是第几组
                if(cal_result == 1)
                    o_bc1(2*dex_result-1:2*dex_result) = [tmp_data_for_IBC(type1_bc+1),tmp_data_for_IBC(type1_bc)];
                elseif(cal_result==0)
                    o_bc2(2*dex_result-1:2*dex_result) = [tmp_data_for_IBC(type1_bc+1),tmp_data_for_IBC(type1_bc)];
                end
            
                cal_type1_bc = cal_type1_bc + 1 ;
            end

            %验证BC信号
            if(ndivide(ringalert_bch_poly,o_bc1(1:31))==0 && ...
                    ndivide(ringalert_bch_poly,o_bc2(1:31))==0)
                data_type = 1;%BC信号验证成功
            end
        end
    end
    %% 验证是否为RA信号

    firstlen = 3*32;
    data_for_type1_RA =  data_reverse_d_uw(1:firstlen);
    o_ra1_type1_RA = nan(1,32);
    o_ra2_type1_RA = nan(1,32);
    o_ra3_type1_RA = nan(1,32);
    cal_type1_RA = 1;%type1计数器
    for type1_RA = length(data_for_type1_RA)-1:-2:1
        cal_result_RA = mod(cal_type1_RA,3);
        dex_result_RA = floor( (cal_type1_RA-1) /3 ) + 1;%判断是第几组
        if(cal_result_RA == 1)
            o_ra1_type1_RA(2*dex_result_RA-1:2*dex_result_RA) = [data_for_type1_RA(type1_RA+1),data_for_type1_RA(type1_RA)];
        elseif(cal_result_RA==2)
            o_ra2_type1_RA(2*dex_result_RA-1:2*dex_result_RA) = [data_for_type1_RA(type1_RA+1),data_for_type1_RA(type1_RA)];
        elseif(cal_result_RA==0)
            o_ra3_type1_RA(2*dex_result_RA-1:2*dex_result_RA) = [data_for_type1_RA(type1_RA+1),data_for_type1_RA(type1_RA)];
        end
    
        cal_type1_RA = cal_type1_RA + 1 ;
    end

    if( ndivide(ringalert_bch_poly,o_ra1_type1_RA(1:31))==0 &&...
        ndivide(ringalert_bch_poly,o_ra2_type1_RA(1:31))==0 &&...
        ndivide(ringalert_bch_poly,o_ra3_type1_RA(1:31))==0)
        data_type = 2;%若为1，则为RA
    end


end