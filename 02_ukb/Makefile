BASEDIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# ---------------------------------------------------------------------
# data

data: tabular_data surface_data

# ---------------------------------------------------------------------
## tabular data
tabular_data: data/04_aseg_tables/aseg.long.table

data/01_tabular_data/data.csv:
	. ./config && \
	cd src/01_data_preparation/01_extract_ukb_tabular_data && \
	python3 extract_data.py

data/02_qdec_tables/sorted.qdec.table.dat: data/01_tabular_data/data.csv
	. ./config && \
	mkdir -p data/02_qdec_tables && \
	cd src/01_data_preparation/02_qdec_table && \
	python3 01_creat_qdec_table.py && \
	bash sortQdecTable.sh

data/04_aseg_tables/aseg.long.table: data/02_qdec_tables/sorted.qdec.table.dat
	cd src/01_data_preparation/04_aseg_table && \
	bash extract_aseg_table.sh

# ---------------------------------------------------------------------
## surface data
surface_data: data/03_concatened_surface_data/lh.volume.fsaverage.sm15.mgh

data/03_concatened_surface_data/lh.volume.fsaverage.sm15.mgh: data/02_qdec_tables/sorted.qdec.table.dat
	cd src/01_data_preparation/03_concat_subject_volumes && \
	mkdir -p logs && \
	bash structuralSurfaceData.sh volume 15

data/03_concatened_surface_data/lh.thickness.fsaverage.sm15.mgh: data/02_qdec_tables/sorted.qdec.table.dat
	cd src/01_data_preparation/03_concat_subject_volumes && \
	mkdir -p logs && \
	bash structuralSurfaceData.sh thickness 15

data/03_concatened_surface_data/lh.area.fsaverage.sm15.mgh: data/02_qdec_tables/sorted.qdec.table.dat
	cd src/01_data_preparation/03_concat_subject_volumes && \
	mkdir -p logs && \
	bash structuralSurfaceData.sh area 15

# ---------------------------------------------------------------------
# Analyses

## Mass-univariate analysis
mua_output := $(BASEDIR)/output/02_mass-univariate_analyses
mua_analyses_to_run := $(mua_output)/01_model01_eduxint
mua_analyses_to_run += $(mua_output)/02_model02_eduxint
mua_analyses_to_run += $(mua_output)/03_model03_edu
mua_analyses_to_run += $(mua_output)/04_model04_edu
mua_analyses_to_run += $(mua_output)/05_model05_bl-agexint
mua_analyses_to_run += $(mua_output)/06_model06_bl-agexint

mass-univariate-analyses: surface_data tabular_data $(mua_analyses_to_run)

mua_src := src/02_mass-univariate_analyses_t
### Analysis 01: 
# y = edu + int + edu*int + sex + bl_age + bl_age^2, 
# testing edu*int
$(mua_output)/01_model01_eduxint:
	cd $(mua_src)/01_model01_eduxint && \
	mkdir -p logs && \
	sbatch submit.sh volume && \
	sbatch submit.sh thickness

### Analysis 02: 
# y = edu + int + edu*int  + sex + bl_age + bl_age^2 + icv, 
# testing edu*int
$(mua_output)/02_model02_eduxint:
	cd $(mua_src)/02_model02_eduxint && \
	mkdir -p logs && \
	sbatch submit.sh volume && \
	sbatch submit.sh area

### Analysis 03: 
# y = edu + int + edu*int + sex + bl_age + bl_age^2, 
# testing edu*int
$(mua_output)/03_model03_edu:
	cd $(mua_src)/03_model03_edu && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 04: 
# y = edu + int + edu + sex + bl_age + bl_age^2 + icv, 
# testing edu
$(mua_output)/04_model04_edu:
	cd $(mua_src)/04_model04_edu && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 05: 
# y = bl_age + int + bl_age*int + sex 
# testing edu
$(mua_output)/05_model05_bl-agexint:
	cd $(mua_src)/05_model05_bl-agexint && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 06: 
# y = bl_age + int + bl_age*int + sex + icv 
# testing edu
$(mua_output)/06_model06_bl-agexint:
	cd $(mua_src)/06_model06_bl-agexint && \
	mkdir -p logs && \
	sbatch submit.sh volume 

### Analysis 07: 
# y = int + bl_age + I(bl_age^2) + sex
# testing edu
$(mua_output)/08_model07_int:
	cd $(mua_src)/08_model07_int && \
	mkdir -p logs && \
	sbatch submit.sh volume 

# -------------------------------------------------------------------- #
# Univariate analysis
ua_output := $(BASEDIR)/output/03_univariate_analyses
ua_analyses_to_run := $(ua_output)/01_hippocampus_gamm
ua_analyses_to_run += $(ua_output)/02_icv_gam

univariate-analyses: tabular_data $(ua_analyses_to_run)

## Hippocampus gamm analyses
$(ua_output)/01_hippocampus_gamm:
	. ./config && \
	cd src/03_univariate_analyses/01_hippocampus_gamm && \
	Rscript render.R && \
	mkdir -p $(ua_output)/01_hippocampus_gamm && \
	mv *.md *.html *.pdf $(ua_output)/01_hippocampus_gamm/.

## icv gam analyses
$(ua_output)/02_icv_gam:
	mkdir -p $(ua_output)/02_icv_gam
	. ./config && \
	cd src/03_univariate_analyses/02_icv_gam && \
	Rscript render.R && \
	mv ICV_analyses_GAM.md ICV_analyses_GAM.html ICV_analyses_GAM.pdf $(ua_output)/02_icv_gam/.

# -------------------------------------------------------------------- #
# Figures

figures: figures/fig_02c.svg figures/fig_02b.svg figures/fig_02a.png figures/fig_S1a_2.svg

# figure 2c
OUTPUTDIR_hc_fig := $(BASEDIR)/output/04_plots/02_hippocampus_gamm
figures/fig_02c.svg:
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_hc_fig)
	. ./config && \
	cd src/04_plots/02_hippocampus_gamm && \
	Rscript 02_hippo_volume_time_GAMM.R && \
	mv *.png *.svg *.pdf $(OUTPUTDIR_hc_fig) && \
	ln -s $(OUTPUTDIR_hc_fig)/02_hippocampus_volume_covariates_included.svg $(BASEDIR)/figures/fig_02c.svg

# figure 2b
OUTPUTDIR_model05_fig := $(BASEDIR)/output/04_plots/03_model05_bl-agexint_cortical_volume_gamm

figures/fig_02b.svg: tabular_data $(mua_output)/05_model05_bl-agexint/stats
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_model05_fig)
	. ./config && \
	cd src/04_plots/03_model05_bl-agexint_cortical_volume_gamm && \
	Rscript 03_model05_bl-agexint_cortical_volume_gamm.R && \
	mv *.svg *.pdf *.png $(OUTPUTDIR_model05_fig) && \
	ln -sf $(OUTPUTDIR_model05_fig)/03_cortical_volume_covariates_included.svg $(BASEDIR)/figures/fig_02b.svg

$(mua_output)/05_model05_bl-agexint/labels: $(mua_output)/05_model05_bl-agexint
	cd src/functions && \
	bash extract_labels.sh volume $(mua_output)/05_model05_bl-agexint && \
	bash merge_labels.sh volume th30 $(mua_output)/05_model05_bl-agexint

$(mua_output)/05_model05_bl-agexint/stats: $(mua_output)/05_model05_bl-agexint/labels
	cd src/functions && \
	bash extract_stats_from_label.sh \
		volume \
		lh \
		sig.lh.th30.abs.sig.volume.label.negative-clusters-merged.label \
		$(mua_output)/05_model05_bl-agexint && \
	bash extract_stats_from_label.sh \
		volume \
		rh \
		sig.rh.th30.abs.sig.volume.label.negative-clusters-merged.label \
		$(mua_output)/05_model05_bl-agexint 

# figure 1b
figures/fig_02a.png: $(mua_output)/05_model05_bl-agexint
	cd src/functions && \
	bash create_figures.sh $(mua_output)/05_model05_bl-agexint
	ln -sf $(mua_output)/05_model05_bl-agexint/figures/publication_p_maps_05_model05_bl-agexint_volume_th30.png \
		figures/fig_02a.png

OUTPUTDIR_icv_fig := $(BASEDIR)/output/04_plots/05_icv_barplot

figures/fig_S1a_2.svg: tabular_data
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_icv_fig)
	. ./config && \
	cd src/04_plots/05_icv_bar_plot && \
	Rscript 05_UKB_ICV_bar_plot.R && \
	mv *.png *.svg *.pdf $(OUTPUTDIR_icv_fig) && \
	ln -s $(OUTPUTDIR_icv_fig)/05_UKB_icv_bar_plot.svg $(BASEDIR)/figures/fig_S1a_2.svg

OUTPUTDIR_offset_fig := $(BASEDIR)/output/04_plots/04_model03_overlap_lb_ukb_cortical_volume_gamm

figures/fig_S1c_2.svg: tabular_data
	mkdir -p figures
	mkdir -p $(OUTPUTDIR_offset_fig)
	mkdir -p $(mua_output)/07_model03_overlap_lb_ukb
	
	cp -r /tsd/p274sharedp23/data/durable/p025-education_brain/output/02_mass-univariate_analyses/08_model04_overlap_lb_ukb/labels/ \
		$(mua_output)/07_model03_overlap_lb_ukb/.
	
	cd src/functions && \
		bash extract_stats_from_label.sh \
			volume lh combined_binarized.sig.lh.th20.abs.sig.masked.volume_C.mgh.label \
			$(mua_output)/07_model03_overlap_lb_ukb
	
	. ./config && \
	cd src/04_plots/04_model03_overlap_lb_ukb_cortical_volume_gamm && \
	Rscript 04_volume_offset_combined_GAMM.R && \
	mv *.png *.svg *.pdf $(OUTPUTDIR_offset_fig) && \
	ln -sf $(OUTPUTDIR_offset_fig)/04_UKB_cortical_volume_covariates_included.svg $(BASEDIR)/figures/fig_S1c_2.svg