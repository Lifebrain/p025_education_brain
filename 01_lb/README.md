# p025-education_brain
LB analyses on education athrophy.

## Description of dataset
Contains the following samples:
- BASE II
- BETULA
- UB
- LCBC
- Cam-CAN

```
n_participants = 735 (368 females)
n_datasets = 1844
Mean interval between last and first scan: 4.1 years
Range first and last scan: 1.1-11.2 years
```
## Run analyses

### Prepare python environment
```
make env
```

### Prepare data
The only manual step in preparing data was to convert the `.xlsx` files to `.csv` files.
```
make data
```
### Run analyses
```
make analyses
```
### Create figures
```
make figures
```

### Clean project
```
make clean
```

## Dependencies
- pandoc
- python3
- R
- matlab

### R-packages
- ggplot2
- mgcv
- brms
- lme4
- lmerTest
- latex2exp

### python modules
- pandas

### Cluster modules used
```
module load Python/3.8.2-GCCcore-9.3.0
module load R/3.6.3-foss-2020a 
module load R/3.5.0
module load matlab/R2017a
```