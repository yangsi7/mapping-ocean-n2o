function K_n2o = n2o_solubility(temp,salt)

% computes the n2o saturation concentration at 1 atm in umol/l
% Temperature in C
% Salt in PSU or g/kg
temp(temp<0)=0;temp(temp>40)=40;
salt(salt<0)=0;salt(salt>40)=40;

a_1 = -165.8802;
a_2 = 222.8743;
a_3 = 92.0792;
a_4 = -1.48425;
b_1 = -0.056235;
b_2 = 0.031619;
b_3 = -0.0048472;

T_K = temp + 273.15;

K_n2o =  (exp(a_1 + a_2 .* (100.0./T_K) + a_3 .* log(T_K./100.0) + a_4 .* (T_K./100.0).^2 ...
+ salt .* (b_1 +b_2 .* (T_K./100.0) + b_3 * (T_K./100.0).^2))).*10^6;
