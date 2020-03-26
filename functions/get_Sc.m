function Sc = get_Sc(T,gas)
% Updated formulation from Wanninkhof 2013
% T is SST in Celcius
% valid over [-2 40] range
% Test: get_Sc(20,'co2') should equal to 668 (Table 1)
T(T<-2.0)=-2.0;T(T>40.0)=40.0;
if strcmp(gas, 'n2o')
    a = 2356.2;
    b = -168.38;
    c = 6.3952;
    d = -0.13422;
    e = 0.0011506;
elseif strcmp(gas, 'co2')
    a = 2116.8;
    b = -136.25;
    c = 4.7353;
    d = -0.092307;
    e = 0.0007555;
end

Sc = a + b.*T + c.*T.^2 + d.*T.^3 + e.*T.^4; 
