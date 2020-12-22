function [] = run_LME(measure, smoothLevel,cores,outputDir)
%[] = run_LME(measure, smoothLevel, cores) Run lme analysis
%   Detailed explanation goes here

%--------------------------------------------------------------------------
    [sortedqdec, subjects, ni, lhmeasure, lhmri, lhsphere, lhcortex, rhmeasure, rhmri, rhsphere, rhcortex] = load_data_mega(measure, smoothLevel);
    X = table2array(readtable('model.dat'));
    [m,n] = size(X);
    
    description = [ 'edu_time' ];
    X(1:5,:)

    display('********************************************************');
    display(['measure: ', measure]);
    display(['smoothness: ', num2str(smoothLevel)]);
    display(['description: ', description]);
    display('********************************************************');
    tic
    [lhTh0, lhRe] = lme_mass_fit_EMinit(X, [1], lhmeasure, ni, lhcortex, 5,cores); % left hemisphere
    [rhTh0, rhRe] = lme_mass_fit_EMinit(X, [1], rhmeasure, ni, rhcortex, 5,cores); % right hemisphere
    toc
    tic
    [lhRgs, lhRgMeans] = lme_mass_RgGrow(lhsphere, lhRe, lhTh0, lhcortex, 2, 95);
    [rhRgs, rhRgMeans] = lme_mass_RgGrow(rhsphere, rhRe, rhTh0, rhcortex, 2, 95);
    toc
    % Save for qc later
    save([outputDir '/covariance_maps/' measure '_' description '.mat'], 'lhTh0', 'lhRe', 'rhTh0', 'rhRe', 'lhRgs', 'lhRgMeans', 'rhRgs', 'rhRgMeans', '-v7.3')
    tic
    [lhstats, lhst] = lme_mass_fit_Rgw(X, [1], lhmeasure, ni, lhTh0, lhRgs, lhsphere,[],'euc','exp',cores);
    [rhstats, rhst] = lme_mass_fit_Rgw(X, [1], rhmeasure, ni, rhTh0, rhRgs, rhsphere,[],'euc','exp',cores);
    toc
    save([outputDir '/power/' measure '_' description '_4power_lhstats.mat'], 'lhstats','lhst', '-v7.3')
    save([outputDir '/power/' measure '_' description '_4power_rhstats.mat'], 'rhstats','rhst', '-v7.3')

    display('********************************************************');
    display('********************** TESTS ***************************');
    display('********************************************************');
    
    contrast = zeros(1,n);
    contrast(n) = 1;
    CM.C = contrast;
    contrastName = 'C';
    
    maketest(CM, contrastName, measure, description, lhstats, lhmri, rhstats, rhmri, lhcortex, rhcortex,cores,outputDir);
    display('********************************************************');
end
