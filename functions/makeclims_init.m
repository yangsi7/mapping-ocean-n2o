function woa = makeclim_init()

% % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Initializes paths and grid info for each variable
% % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Simon Yang, March 2019

% set up paths ans names

% Temperature
woa{1}.path = '';
woa{1}.file = 'woa18_decav_t';
woa{1}.suf = '_04.nc';
woa{1}.dataset='woa';
woa{1}.varname='t_an';
woa{1}.res = '0p25';
woa{1}.sizex=1440;
woa{1}.sizey=720;
woa{1}.sizek_surf = 57;
woa{1}.sizek=102;
woa{1}.sizel_month=12;
woa{1}.sizel_seas=4;
woa{1}.tint=1;
woa{1}.nc.varnames = {'temp', 'temp_inpaint'};
woa{1}.nc.dims = {'xyzt', 'xyzt'};
woa{1}.nc.sname = {'temp', 'temp'};
woa{1}.nc.lname = {'temperature', 'temperature'};
woa{1}.nc.units = {'C', 'C'};
woa{1}.nc.xyzdim='woa18';
woa{1}.nc.tdim='clim';


% Salinity;
woa{2}.path = ''
woa{2}.file = 'woa18_decav_s';
woa{2}.suf = '_04.nc';
woa{2}.dataset='woa';
woa{2}.varname='s_an';
woa{2}.res = '0p25';
woa{2}.sizex=1440;
woa{2}.sizey=720;
woa{2}.sizek_surf = 57;
woa{2}.sizek=102;
woa{2}.sizel_month=12;
woa{2}.sizel_seas=4;
woa{2}.tint=1;
woa{2}.nc.varnames = {'salt', 'salt_inpaint'};
woa{2}.nc.dims = {'xyzt' 'xyzt'};
woa{2}.nc.sname = {'salt' 'salt'};
woa{2}.nc.lname = {'salinity' 'salinity'};
woa{2}.nc.units = {'g/kg' 'g/kg'};
woa{2}.nc.xyzdim='woa18';
woa{2}.nc.tdim='clim';

% Oxygen
woa{3}.path = '';
woa{3}.file = 'woa18_all_o';
woa{3}.suf = '_01.nc';
woa{3}.dataset='woa';
woa{3}.varname='o_an';
woa{3}.res = '1p0';
woa{3}.sizex=360;
woa{3}.sizey=180;
woa{3}.sizek_surf = 57;
woa{3}.sizek=102;
woa{3}.sizel_month=12;
woa{3}.sizel_seas=4;
woa{3}.tint=1;
woa{3}.nc.varnames = {'o2', 'o2_inpaint'};
woa{3}.nc.dims = {'xyzt' 'xyzt'};
woa{3}.nc.sname = {'oxygen' 'oxygen'};
woa{3}.nc.lname = {'oxygen' 'oxygen'};
woa{3}.nc.units = {'umol/kg' 'umol/kg'};
woa{3}.nc.xyzdim='woa13';
woa{3}.nc.tdim='clim';

% AOU
woa{4}.path = '';
woa{4}.file = 'woa18_all_A';
woa{4}.suf = '_01.nc';
woa{4}.dataset='woa';
woa{4}.varname='A_an';
woa{4}.res = '1p0';
woa{4}.sizex=360;
woa{4}.sizey=180;
woa{4}.sizek_surf = 57;
woa{4}.sizek=102;
woa{4}.sizel_month=12;
woa{4}.sizel_seas=4;
woa{4}.tint=1;
woa{4}.nc.varnames = {'aou', 'aou_inpaint'};
woa{4}.nc.dims = {'xyzt' 'xyzt'};
woa{4}.nc.sname = {'AOU' 'AOU'};
woa{4}.nc.lname = {'Apparent oxygen utilization' 'Apparent oxygen utilization'};
woa{4}.nc.units = {'umol/kg' 'umol/kg'};
woa{4}.nc.xyzdim='woa13';
woa{4}.nc.tdim='clim';

%Nitrate
woa{5}.path = '';
woa{5}.file = 'woa18_all_n';
woa{5}.suf = '_01.nc';
woa{5}.dataset='woa';
woa{5}.varname='n_an';
woa{5}.res = '1p0';
woa{5}.sizex=360;
woa{5}.sizey=180;
woa{5}.sizek_surf = 43;
woa{5}.sizek=102;
woa{5}.sizel_month=12;
woa{5}.sizel_seas=4;
woa{5}.tint=0;
woa{5}.nc.varnames = {'no3', 'no3_inpaint'};
woa{5}.nc.dims = {'xyzt' 'xyzt'};
woa{5}.nc.sname = {'NO3' 'NO3'};
woa{5}.nc.lname = {'Nitrate' 'Nitrate'};
woa{5}.nc.units = {'umol/kg' 'umol/kg'};
woa{5}.nc.xyzdim='woa13';
woa{5}.nc.tdim='clim';

%Phosphate
woa{6}.path = '';
woa{6}.file = 'woa18_all_p';
woa{6}.suf = '_01.nc';
woa{6}.dataset='woa';
woa{6}.varname='p_an';
woa{6}.res = '1p0';
woa{6}.sizex=360;
woa{6}.sizey=180;
woa{6}.sizek_surf = 43;
woa{6}.sizek=102;
woa{6}.sizel_month=12;
woa{6}.sizel_seas=4;
woa{6}.tint=0;
woa{6}.nc.varnames = {'po4', 'po4_inpaint'};
woa{6}.nc.dims = {'xyzt' 'xyzt'};
woa{6}.nc.sname = {'PO4' 'PO4'};
woa{6}.nc.lname = {'Phosphate' 'Phosphate'};
woa{6}.nc.units = {'umol/kg' 'umol/kg'};
woa{6}.nc.xyzdim='woa13';
woa{6}.nc.tdim='clim';

