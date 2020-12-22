% do_comparison.m
% merge p-maps for ukb and lb
% Every vertex gets the value:
%   - 0 (no effect), 
%   - 1 (effect in LB or UKB)
%   - 2 (overlap between UKB and LB)
clear all

output_dir = getenv('output_dir')

INPUT_DIR = strcat(output_dir,"/p_maps-source")
OUTPUT_DIR =strcat(output_dir,"/p_maps")

for hemi=["lh","rh"]
    hemi
    for threshold=["th00","th13","th20"]
        threshold
        lb_file = dir(char(strcat(INPUT_DIR,"/lb.sig."+hemi+"."+threshold+"*volume*.mgh")));
        ukb_file = dir(char(strcat(INPUT_DIR,"/ukb.sig."+hemi+"."+threshold+"*volume*.mgh")));
        
        lb_filename = lb_file.folder + "/" + lb_file.name;
        [Y_lb,mri_lb] = fs_read_Y(char(lb_filename));

        ukb_filename = ukb_file.folder + "/" + ukb_file.name;
        [Y_ukb,mri_ukb] = fs_read_Y(char(ukb_filename));
        
        n = length(Y_lb);

        Y_combined = zeros(1,n);
        lindex=0;
        lvals=0;
        % uncorrected maps
        k=1;
        for i=1:n
            if Y_lb(i) > 1.3 && Y_ukb(i) > 1.3
                Y_combined(i)=2;
                % for label
                lindex(k) = i-1;
                lvals(k) = 0;
                k=k+1;
            elseif Y_lb(i) > 1.3 || Y_ukb(i) > 1.3
                Y_combined(i)=1;
            else
                Y_combined(i)=0;
            end
        end
        
        output_name = strcat(OUTPUT_DIR,strrep(lb_file.name,'lb','/combined_binarized'));
        
        fs_write_Y(Y_combined,mri_lb,char(output_name))
        if(length(lindex) > 1)
            output_name_label = strcat(output_dir,"/labels/",strrep(lb_file.name,'lb','/combined_binarized'),".label");
            write_label(lindex,zeros(length(lindex),3),lvals,output_name_label,"fsaverage","voxel")
        end
        
    end
end