%2进制到10进制,输入num为一维数组

function result = two2ten(num)
    tmp = 0;
    len = length(num);
    for now =len:-1:1
        tmp = tmp + num(now)* power(2,len-now);
       
    end
    result = tmp;
end