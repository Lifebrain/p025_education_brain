% Confidence interval on all data
close all;
addpath('../../common_data_functions/matlab_functions');
addpath('../../../data/07_ukb_lb_merged/01_qdec_tables')
addpath('../../../data/07_ukb_lb_merged/02_concatenated_surface_data')

output_dir='../../../output/06_mega_mass-univariate_analyses/01_model03_eduxint/power'

addpath(output_dir)

% Load data, so that we can save it properly
disp("Function: load_data_mega()")
tic
[sortedqdec, subjects, ni, lhmeasure, lhmri, lhsphere, lhcortex, rhmeasure, rhmri, rhsphere, rhcortex] = load_data_mega('volume', 15);
toc

for hemi = ["lh" "rh"]
    disp(['Loading .mat, for hemi: ',hemi])
    tic
    load(['volume_edu_time_4power_' char(hemi) 'stats.mat'])
    toc

    if(hemi=="lh")
        stats = lhstats;
        mri = lhmri;
    elseif(hemi=="rh")
        stats = rhstats;
        mri = rhmri;
    end

    % load ed to calculate the std of the edu and int params
    edu_std = 1;
    int_std = std(getData('years'));
    edu_int_std = edu_std*int_std;

    n = length(stats);

    % We want to extract edu, int and eduxint Bhat and confidence intervals

    k_all = [2 3 13] % edu, int, eduxint
    desc = ["edu","int","eduxint"]
    std_to_correct = [edu_std, int_std, edu_int_std]

    for i = 1:3

        ci_min = zeros(1,n);
        ci_max = zeros(1,n);
        Bhat_save = zeros(1,n);

        k = k_all(i)
        description = char(desc(i))
        std_k = std_to_correct(i)

        tic
        for (j = 1:n)
            %disp(j)
            Bhat = stats(j).Bhat;
            CovBhat = stats(j).CovBhat;
            try
                tmp_int_min = Bhat(k)/std_k + norminv(0.025)*sqrt(CovBhat(k,k))/std_k;
                tmp_int_max = Bhat(k)/std_k + norminv(0.975)*sqrt(CovBhat(k,k))/std_k;
                Bhat_save(j) = Bhat(k)/std_k;
            catch
                tmp_int_min = nan;
                tmp_int_max = nan;
                Bhat_save(j) = nan;
            end
            ci_min(j) = tmp_int_min;
            ci_max(j) = tmp_int_max;
            
        end
        toc
        
        figure(1)
        histogram(Bhat_save)
        title(['Bhat of ' description])
        saveas(gcf,[char(output_dir) '/hist_Bhat_' description '.png'])
        figure(2)
        histogram(ci_min)
        title(['ci min of ' description])
        saveas(gcf,[char(output_dir) '/hist_ci_min_' description '.png'])

        figure(3)
        histogram(ci_max)
        title(['ci max of ' description])
        saveas(gcf,[char(output_dir) '/hist_ci_max_' description '.png'])
        
        % To be able to use fs_write_Y
        mri.volsz(4) = 1;

        % Save as a .mgh file
        fs_write_Y(Bhat_save,mri,[char(output_dir) '/../figures/power/histogram/' char(hemi) '_Bhat_' description '.mgz'])
        fs_write_Y(ci_min,mri,[char(output_dir) '/../figures/power/histogram/' char(hemi) '_conf-min_' description '.mgz'])
        fs_write_Y(ci_max,mri,[char(output_dir) '/../figures/power/histogram/' char(hemi) '_conf-max_' description '.mgz'])
    end
end
