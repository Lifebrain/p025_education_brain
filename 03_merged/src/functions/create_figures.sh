#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path/to/mass-univariate/output/dir>"
    exit 0
else
    # Directory where results are located.
    output_dir=$1
fi

source ../../config

# For tksurfer to work, we need freesurfer 6.0
export FREESURFER_HOME=/cluster/projects/p274/tools/mri/freesurfer/freesurfer.6.0.1
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=$FREESURFER_HOME/subjects

#set -eET

base_name=$(basename $output_dir)
cd $output_dir

rm -rf figures

mkdir -p figures/normal/p_maps
mkdir -p figures/normal/label
mkdir -p figures/publication/p_maps
mkdir -p figures/publication/label

tksurfer fsaverage lh inflated -tcl $COMMON_FUNCTIONS/tcl/save_tiff.tcl
tksurfer fsaverage rh inflated -tcl $COMMON_FUNCTIONS/tcl/save_tiff.tcl
tksurfer fsaverage lh inflated.400 -tcl $COMMON_FUNCTIONS/tcl/save_pub_tiff.tcl
tksurfer fsaverage rh inflated.400 -tcl $COMMON_FUNCTIONS/tcl/save_pub_tiff.tcl

if [ -d $output_dir/labels ]; then
    tksurfer fsaverage lh inflated -tcl $COMMON_FUNCTIONS/tcl/save_label.tcl
    tksurfer fsaverage rh inflated -tcl $COMMON_FUNCTIONS/tcl/save_label.tcl
    tksurfer fsaverage lh inflated.400 -tcl $COMMON_FUNCTIONS/tcl/save_pub_label.tcl
    tksurfer fsaverage rh inflated.400 -tcl $COMMON_FUNCTIONS/tcl/save_pub_label.tcl
fi

# Make background transparent on the normal and publication figures, and swap white with black on label
for type in "normal" "publication"
do
    for figure in $(ls figures/$type/p_maps/*.tif figures/$type/label/*.tif)
    do
        convert $figure -fuzz 1% -transparent "#000000" ${figure/.tif/_transparent.png}
        convert ${figure/.tif/_transparent.png} -fuzz 1% -fill black -opaque white ${figure/.tif/_transparent.png}
        convert ${figure/.tif/_transparent.png} -fuzz 1% -transparent "#000000" ${figure/.tif/_transparent.png}
    done
done

# Extract the colorbar
convert $figure \
    -fuzz 1% \
    -transparent "#000000" \
    -crop 100x210+500+390\
    -fill black \
    -opaque white \
    -pointsize 14 \
    -font helvetica \
    -stroke black \
    -strokewidth 0.2 \
    -draw "text 503,410 'log10(p_value)'" figures/bar.png

for figure_type in "normal" "publication"
do
    for measure in "volume" "thickness"
    do
        for type in "p_maps" "label"
        do
            src_label=
            if [ $type == "label" ]; then
                src_label="negative-clusters-merged"
            fi
            figure_list="
                figures/${figure_type}/${type}/*sig.rh.${measure}*${src_label}*lateral*.png \
                figures/${figure_type}/${type}/*sig.lh.${measure}*${src_label}*lateral*.png \
                figures/${figure_type}/${type}/*sig.rh.${measure}*${src_label}*medial*.png \
                figures/${figure_type}/${type}/*sig.lh.${measure}*${src_label}*medial*.png"
            figures_to_concat=""
            for figure in $figure_list;
            do
                if [ -e $figure ]; then
                    figures_to_concat="$figures_to_concat $figure"
                fi
            done
            echo $figures_to_concat
            if [ $(ls figures/${figure_type}/${type}/*sig.??.${measure}*.png | wc -l) -gt 1 ]; then
                montage -mode concatenate -background transparent -crop 500x350+50+125 \
                    $figures_to_concat \
                    figures/${figure_type}_${type}_${base_name}_${measure}_th00.png
                
                convert figures/${figure_type}_${type}_${base_name}_${measure}_th00.png \
                    -resize 512x512 \
                    figures/${figure_type}_${type}_${base_name}_${measure}_th00.png

                if [ $type != "label" ]; then
                    montage -mode concatenate -background transparent \
                        figures/${figure_type}_${type}_${base_name}_${measure}_th00.png figures/bar.png \
                        figures/${figure_type}_${type}_${base_name}_${measure}_th00.png
                    
                     montage -mode concatenate -background transparent -crop 500x350+50+125 -tile x1 \
                            $figures_to_concat figures/bar.png \
                            figures/report_${figure_type}_${type}_${base_name}_${measure}_th${th}.png
                fi
            fi
        done
    done

    for th in "13" "20" "30"
    do
        for measure in "volume" "thickness"
        do 
            for type in "p_maps" "label"
            do
                src_label=
                if [ $type == "label" ]; then
                    src_label="negative-clusters-merged"
                fi
                figure_list="\
                    figures/${figure_type}/${type}/*sig.rh*th${th}*${measure}*${src_label}*lateral*.png \
                    figures/${figure_type}/${type}/*sig.lh*th${th}*${measure}*${src_label}*lateral*.png \
                    figures/${figure_type}/${type}/*sig.rh*th${th}*${measure}*${src_label}*medial*.png \
                    figures/${figure_type}/${type}/*sig.lh*th${th}*${measure}*${src_label}*medial*.png"
                figures_to_concat=""
                for figure in $figure_list;
                do
                    if [ -e $figure ]; then
                        figures_to_concat="$figures_to_concat $figure"
                    fi
                done
                echo $figures_to_concat
                if [ $(ls figures/${figure_type}/${type}/*sig.*th${th}*${measure}*.png | wc -l) -gt 1 ]; then
                    montage -mode concatenate -background transparent -crop 500x350+50+125 \
                        $figures_to_concat \
                        figures/${figure_type}_${type}_${base_name}_${measure}_th${th}.png

                    convert figures/${figure_type}_${type}_${base_name}_${measure}_th${th}.png \
                        -resize 512x512 \
                        figures/${figure_type}_${type}_${base_name}_${measure}_th${th}.png
                    
                    montage -mode concatenate -background transparent -crop 500x350+50+125 -tile x1 \
                        $figures_to_concat \
                        figures/report_${figure_type}_${type}_${base_name}_${measure}_th${th}.png

                    if [ $type != "label" ] && [ "${base_name}" != "08_model04_overlap_lb_ukb" ]; then
                        montage -mode concatenate -background transparent \
                            figures/${figure_type}_${type}_${base_name}_${measure}_th${th}.png figures/bar.png \
                            figures/${figure_type}_${type}_${base_name}_${measure}_th${th}.png
                    fi
                fi
            done
        done
    done
done
