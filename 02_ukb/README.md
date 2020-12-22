# p025_education_brain/02_ukb
The same education analysis done for the LCBC data, but, done on the UKB data.

## Run analyses

### Prepare data
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
