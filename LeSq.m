function position = LeSq(VisSatinfo,Pos,settings,freq)
m=length(VisSatinfo);
c=settings.c;
f_0=settings.f;
T_0=0;
Pos_guess=[Pos,T_0]';
G=ones(m,4);%状态转移矩阵
k=1;
toler=1;
while toler>=1e-9
    for i=1:m
        vxi=VisSatinfo(i).vel(1);
        vyi=VisSatinfo(i).vel(2);
        vzi=VisSatinfo(i).vel(3);
        delta_x=Pos_guess(1:3,1)-VisSatinfo(i).Pos;
        ri=norm(delta_x);
        G(i,1)=vxi/ri-( Pos_guess(1)-VisSatinfo(i).Pos(1) )*( (Pos_guess(1:3)-VisSatinfo(i).Pos)'*VisSatinfo(i).vel )/(ri^3);
        G(i,2)=vyi/ri-( Pos_guess(2)-VisSatinfo(i).Pos(2) )*( (Pos_guess(1:3)-VisSatinfo(i).Pos)'*VisSatinfo(i).vel )/(ri^3);
        G(i,3)=vzi/ri-( Pos_guess(3)-VisSatinfo(i).Pos(3) )*( (Pos_guess(1:3)-VisSatinfo(i).Pos)'*VisSatinfo(i).vel )/(ri^3);
        RI(i)=ri;
    end
    G(:,1:3)=2*pi*f_0/c.*G(:,1:3);
    % B=inv(G'*G+1e-3*eye(4))*G';
    f_predict=zeros(m,1);
    for i=1:m
    f_predict(i)=(1+VisSatinfo(i).vel'*(Pos_guess(1:3)-VisSatinfo(i).Pos)/(c*RI(i)))*f_0+Pos_guess(4);
    end
    df=freq-f_predict;
    [dx, iter] = gaussSeidel(G'*G, G'*df, 1e-6);
    % dx=B*df;
    Pos_guess=Pos_guess+dx;
    toler=norm(df);
    error=norm(Pos_guess(1:3)-Pos);
    k=k+1;
    if k>=1e5
        disp('未收敛')
        % stop
        break
        
    end 
end
position=Pos_guess(1:3);

end

