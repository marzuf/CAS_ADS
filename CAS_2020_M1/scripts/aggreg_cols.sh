#!/usr/bin/bash

# workflow

# ./aggreg_cols.sh

rscript="aggreg_cols.R"



runCMD() {
  echo "> $1"
  eval $1
}

checkFolder() {
if [[ ! -d  $2 ]]; then
    echo "... $1 ($2) does not exist !"
    exit 1
fi
}
all_chromo=( "chr"{1..22} )
#all_chromo=( "chr22" )

binSignalFolder="/mnt/ed4/marie/scripts/EZH2_final_MAPQ/29_05_20kb_GSE63525/GM12878/TopDom"


all_peak_folders=( "BROADPEAKS")


#all_folds=$(	IFS=, ; echo "${all_peak_folders[*]}")
all_folds="$( printf "_%s" "${all_peak_folders[@]}" )"

inFolder="FINAL_DATA_FILES${all_folds}"

checkFolder inFolder $inFolder

outFolder="FINAL_AGGREG_DATA_FILES${all_folds}"
cmd="mkdir -p $outFolder"
runCMD "$cmd"


for chromo in "${all_chromo[@]}"; do
	cmd="Rscript $rscript $inFolder/GM12878_${chromo}_final.txt $outFolder/GM12878_${chromo}_final_agg.txt"
	runCMD "$cmd"
	
	#break #<<<<<<

done # end-iterating over chromo


exit 0


