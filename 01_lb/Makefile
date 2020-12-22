BASEDIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

env/education_brain:
	# Install python environment
	mkdir -p env && \
	pip install virtualenv && \
	virtualenv --python=python3 env/education_brain && \
	. env/education_brain/bin/activate && \
	pip install pandas

# -------------------------------------------------------------------- #
# Tabular data creation

# 1. Copy raw data from each site. The .xlsx files was converted to 
#    .csv by hand.
data/01_tabular_data: 
	cd src/01_data_preparation/01_extract_tabular_data && \
	bash 01_extract_tabular_data.sh

# 2. Make .csv data uniform for each site.
data/02_tabular_data_edited: data/01_tabular_data
	cd src/01_data_preparation/02_edit_tabular_data/ && \
	bash 02_edit_tabular_data.sh

# 3. Create qdec tables, sort and merge them.
data/03_qdec_tables/ALL.sorted.qdec.table.dat: env/education_brain data/02_tabular_data_edited
	. env/education_brain/bin/activate && \
	cd src/01_data_preparation/03_create_qdec_tables/ && \
	bash 03_create_qdec_tables_main.sh

# Extract FreeSurfer aseg stats
data/05_aseg_tables/ALL.aseg.long.table: data/03_qdec_tables/ALL.sorted.qdec.table.dat
	cd src/01_data_preparation/05_extract_aseg_tables/ && \
	bash 05_extract_aseg_tables.sh

data/06_above_below_median_data/above_below_median_hippocampus_icv.txt: data/05_aseg_tables/ALL.aseg.long.table
	mkdir -p data/06_above_below_median_data
	. env/education_brain/bin/activate && \
	. ./config && \
	cd src/01_data_preparation/06_above_below_median/ && \
	python generate_above_below_median_data.py

tabular_data: data/06_above_below_median_data/above_below_median_hippocampus_icv.txt

# -------------------------------------------------------------------- #
# Surface data
data/04_concatened_surface_data/ALL.lh.volume.fsaverage.sm15.mgh: data/03_qdec_tables/ALL.sorted.qdec.table.dat
	cd src/01_data_preparation/04_concatenate_surfaces/ && \
	bash 04_concatenate_surface_data.sh volume

data/04_concatened_surface_data/ALL.lh.thickness.fsaverage.sm15.mgh: data/03_qdec_tables/ALL.sorted.qdec.table.dat
	cd src/01_data_preparation/04_concatenate_surfaces/ && \
	bash 04_concatenate_surface_data.sh thickness

data/04_concatened_surface_data/ALL.lh.area.fsaverage.sm15.mgh: data/03_qdec_tables/ALL.sorted.qdec.table.dat
	cd src/01_data_preparation/04_concatenate_surfaces/ && \
	bash 04_concatenate_surface_data.sh area

surface_data: data/04_concatened_surface_data/ALL.lh.volume.fsaverage.sm15.mgh \
			  data/04_concatened_surface_data/ALL.lh.thickness.fsaverage.sm15.mgh \
			  data/04_concatened_surface_data/ALL.lh.area.fsaverage.sm15.mgh \
# -------------------------------------------------------------------- #

# Create data
data: tabular_data surface_data

# -------------------------------------------------------------------- #
# Analyses
analyses: mass-univariate-analyses univariate-analyses bayes
# -------------------------------------------------------------------- #
## Mass-univariate analysis
mua_output := $(BASEDIR)/output/02_mass-univariate_analyses
mua_analyses_to_run := $(mua_output)/01_model01_eduxint
mua_analyses_to_run += $(mua_output)/02_model02_eduxint
mua_analyses_to_run += $(mua_output)/03_model03_eduxint
mua_analyses_to_run += $(mua_output)/04_model04_edu
mua_analyses_to_run += $(mua_output)/05_model05_edu
mua_analyses_to_run += $(mua_output)/06_model06_bl-agexint
mua_analyses_to_run += $(mua_output)/07_model07_bl-agexint

mass-univariate-analyses: surface_data tabular_data $(mua_analyses_to_run)

### Analysis 01: 
# y = edu + int + edu*int + scanner + sex + bl_age + bl_age^2, 
# testing edu*int
$(mua_output)/01_model01_eduxint:
	cd src/02_mass-univariate_analyses/01_model01_eduxint && \
	mkdir -p logs && \
	sbatch submit.sh volume && \
	sbatch submit.sh thickness

### Analysis 02: 
# y = edu + int + edu*int + scanner + sex + bl_age + bl_age^2 + icv, 
# testing edu*int
$(mua_output)/02_model02_eduxint:
	cd src/02_mass-univariate_analyses/02_model02_eduxint && \
	mkdir -p logs && \
	sbatch submit.sh volume && \
	sbatch submit.sh area

### Analysis 03: 
# y = edu + int + edu*int + sex + bl_age + bl_age^2, 
# testing edu*int
$(mua_output)/03_model03_eduxint:
	cd src/02_mass-univariate_analyses/03_model03_eduxint && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 04: 
# y = edu + int + edu + sex + bl_age + bl_age^2, 
# testing edu
$(mua_output)/04_model04_edu:
	cd src/02_mass-univariate_analyses/04_model04_edu && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 05: 
# y = edu + int + edu + sex + bl_age + bl_age^2 + icv, 
# testing edu
$(mua_output)/05_model05_edu:
	cd src/02_mass-univariate_analyses/05_model05_edu && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 06: 
# y = bl_age + int + bl_age*int + sex + scanner 
# testing bl_age*int
$(mua_output)/06_model06_bl-agexint:
	cd src/02_mass-univariate_analyses/06_model06_bl-agexint && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 07: 
# y = bl_age + int + bl_age*int + sex + scanner + icv 
# testing bl_age*int
$(mua_output)/07_model07_bl-agexint:
	cd src/02_mass-univariate_analyses/07_model07_bl-agexint && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 08: 
# Find out where UKB and LB overlaps for model04
$(mua_output)/08_model04_overlap_lb_ukb:
	cd src/02_mass-univariate_analyses/08_model04_overlap_lb_ukb && \
	bash submit.sh

# -------------------------------------------------------------------- #
# Univariate analysis
ua_output := $(BASEDIR)/output/03_univariate_analyses
ua_analyses_to_run := $(ua_output)/01_hippocampus_gamm
ua_analyses_to_run += $(ua_output)/02_icv_gam

univariate-analyses: tabular_data $(ua_analyses_to_run)

## Hippocampus gamm analyses
$(ua_output)/01_hippocampus_gamm:
	mkdir -p $(ua_output)/01_hippocampus_gamm
	. ./config && \
	cd src/03_univariate_analyses/01_hippocampus_gamm && \
	Rscript render.R && \
	mv *.md *.html *.pdf *_files $(ua_output)/01_hippocampus_gamm/.

## icv gam analyses
$(ua_output)/02_icv_gam:
	mkdir -p $(ua_output)/02_icv_gam
	. ./config && \
	cd src/03_univariate_analyses/02_icv_gam && \
	Rscript render.R && \
	mv ICV_analyses_GAM.md ICV_analyses_GAM.html ICV_analyses_GAM.pdf $(ua_output)/02_icv_gam/.

# -------------------------------------------------------------------- #
# Bayesian hypothesis testing
bayes: output/05_bayes

OUTPUT_BAYES := $(BASEDIR)/output/05_bayes
output/05_bayes: tabular_data
	mkdir -p $(OUTPUT_BAYES)
	. ./config && \
	cd src/05_bayes && \
	bash submit.sh && \
	mv *.pdf *.rds $(OUTPUT_BAYES)/.

# -------------------------------------------------------------------- #
# Figures
figures: figures/fig_01a.svg figures/fig_01b.png figures/fig_01c.svg figures/fig_01d.svg figures/fig_S1a_1.svg figures/fig_S1c_1.svg

# figure 1d
OUTPUTDIR_hc_fig := $(BASEDIR)/output/04_plots/02_hippocampus_gamm
figures/fig_01d.svg:
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_hc_fig)
	. ./config && \
	cd src/04_plots/02_hippocampus_gamm && \
	Rscript 02_hippo_volume_time_GAMM.R && \
	mv *.png *.svg *.pdf $(OUTPUTDIR_hc_fig) && \
	ln -sf $(OUTPUTDIR_hc_fig)/02_LB_hippocampus_covariates_included.svg $(BASEDIR)/figures/fig_01d.svg

# figure 1a
OUTPUTDIR_median_fig := $(BASEDIR)/output/04_plots/05_median_range_plot
figures/fig_01a.svg: tabular_data
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_median_fig)
	. ./config && \
	cd src/04_plots/05_median_range_plot && \
	Rscript 05_median_plot.R && \
	mv *.svg *.png $(OUTPUTDIR_median_fig) && \
	ln -sf $(OUTPUTDIR_median_fig)/05_median_plot.svg $(BASEDIR)/figures/fig_01a.svg

# figure 1c
OUTPUTDIR_model06_fig := $(BASEDIR)/output/04_plots/03_model06_bl-agexint_cortical_volume_gamm

figures/fig_01c.svg: $(mua_output)/06_model06_bl-agexint/stats
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_model06_fig)
	. ./config && \
	cd src/04_plots/03_model06_bl-agexint_cortical_volume_gamm && \
	Rscript 03_model06_bl-agexint_cortical_volume_gamm.R && \
	mv *.svg *.pdf *.png $(OUTPUTDIR_model06_fig) && \
	ln -sf $(OUTPUTDIR_model06_fig)/03_LB_cortical_volume_covariates_included.svg $(BASEDIR)/figures/fig_01c.svg

$(mua_output)/06_model06_bl-agexint/labels: $(mua_output)/06_model06_bl-agexint
	cd src/functions && \
	bash extract_labels.sh volume $(mua_output)/06_model06_bl-agexint && \
	bash merge_labels.sh volume th30 $(mua_output)/06_model06_bl-agexint

$(mua_output)/06_model06_bl-agexint/stats: $(mua_output)/06_model06_bl-agexint/labels
	cd src/functions && \
	bash extract_stats_from_label.sh \
		volume \
		lh \
		sig.lh.th30.abs.sig.volume.label.negative-clusters-merged.label \
		$(mua_output)/06_model06_bl-agexint && \
	bash extract_stats_from_label.sh \
		volume \
		rh \
		sig.rh.th30.abs.sig.volume.label.negative-clusters-merged.label \
		$(mua_output)/06_model06_bl-agexint 

# figure 1b
figures/fig_01b.png: $(mua_output)/06_model06_bl-agexint
	cd src/functions && \
	bash create_figures.sh $(mua_output)/06_model06_bl-agexint
	ln -sf $(mua_output)/06_model06_bl-agexint/figures/publication_p_maps_06_model06_bl-agexint_volume_th30.png \
		figures/fig_01b.png

OUTPUTDIR_icv_fig := $(BASEDIR)/output/04_plots/06_icv_barplot

figures/fig_S1a_1.svg: tabular_data
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_icv_fig)
	. ./config && \
	cd src/04_plots/06_icv_barplot && \
	Rscript 06_icv_bar_plot.R && \
	mv *.png *.svg *.pdf $(OUTPUTDIR_icv_fig) && \
	ln -s $(OUTPUTDIR_icv_fig)/06_LB_icv_bar_plot.svg $(BASEDIR)/figures/fig_S1a_1.svg

OUTPUTDIR_overlap_fig := $(BASEDIR)/output/04_plots/04_model04_overlap_lb_ukb_cortical_volume_gamm

figures/fig_S1c_1.svg: $(mua_output)/08_model04_overlap_lb_ukb
	mkdir -p $(OUTPUTDIR_overlap_fig)
	. ./config && \
	cd src/04_plots/04_model04_overlap_lb_ukb_cortical_volume_gamm && \
	Rscript 04_offset_effect_combined_GAMM.R && \
	mv *.svg *.png *.pdf $(OUTPUTDIR_overlap_fig)/.
	ln -sf $(OUTPUTDIR_overlap_fig)/04_LB_offset_cortical_volume_covariates_included.svg figures/fig_S1c_1.svg

figures/fig_S1b.png:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/08_model04_overlap_lb_ukb
	ln -sf $(mua_output)/08_model04_overlap_lb_ukb/figures/publication_p_maps_08_model04_overlap_lb_ukb_volume_th20.png \
		figures/fig_S1b.png

# -------------------------------------------------------------------- #
# Report
report: report/LB_surface_models.pdf create_report_figures

report/LB_surface_models.pdf:
	cd report && \
	Rscript render.R

report_figures :=$(mua_output)/01_model01_eduxint/figures
report_figures +=$(mua_output)/02_model02_eduxint/figures
report_figures +=$(mua_output)/03_model03_eduxint/figures
report_figures +=$(mua_output)/04_model04_edu/figures
report_figures +=$(mua_output)/05_model05_edu/figures
report_figures +=$(mua_output)/06_model06_bl-agexint/figures
report_figures +=$(mua_output)/07_model07_bl-agexint/figures

create_report_figures: $(report_figures)

# Create figures from all analyses
$(mua_output)/01_model01_eduxint/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/01_model01_eduxint

$(mua_output)/02_model02_eduxint/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/02_model02_eduxint

$(mua_output)/03_model03_eduxint/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/03_model03_eduxint

$(mua_output)/04_model04_edu/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/04_model04_edu

$(mua_output)/05_model05_edu/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/05_model05_edu

$(mua_output)/06_model06_bl-agexint/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/06_model06_bl-agexint

$(mua_output)/07_model07_bl-agexint/figures:
	cd src/functions && \
	bash create_figures.sh $(mua_output)/07_model07_bl-agexint

clean_data:
	rm -rf data/03_qdec_tables
	rm -rf data/04_concatened_surface_data
	rm -rf data/05_aseg_tables
	rm -rf data/06_above_below_median_data

clean_output:
	rm -rf output

clean_env:
	rm -rf env/

clean_logs:
	rm -rf src/02_mass-univariate_analyses/*/logs