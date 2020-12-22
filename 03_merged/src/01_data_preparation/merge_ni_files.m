% Purpose: merge ni.mat files

addpath('../../../data/07_ukb_lb_merged/01_qdec_tables')

ni_path = '../../../data/07_ukb_lb_merged/01_qdec_tables/';

ni_merge = [];

fid = fopen('ni.mat_order_to_load.txt');
while true
    tline = fgetl(fid);
    if ~ischar(tline); break; end   %end of file
    disp(tline);
    load(tline);
    ni_merge = [ni_merge; ni];
end

ni = ni_merge;

save([ni_path 'MEGA.ni.mat'],'ni');