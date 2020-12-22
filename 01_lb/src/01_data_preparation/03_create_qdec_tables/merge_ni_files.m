% Purpose: merge ni.mat files

QDEC_DIR = getenv('QDEC_DATA_DIR')

addpath(QDEC_DIR)

ni_files = dir([QDEC_DIR '/*.ni.mat']);

ni_merge = [];

for k = 1:length(ni_files)
    if contains(ni_files(k).name,"ALL") == 0
        load(ni_files(k).name);
        ni_merge = [ni_merge; ni];
    end
end

ni = ni_merge;

save([QDEC_DIR '/ALL.ni.mat'],'ni')