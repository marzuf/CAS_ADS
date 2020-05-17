#!/usr/bin/bash

# workflow

# first rename the bed files so that they contain accession and protein name

# -> for each chromo
# take the file from GM12878 with bin coordinates
# extract bin coordinates as BED format
# for each of peak file available -> sum over the TAD coordinates


runCMD() {
  echo "> $1"
  #eval $1
}

checkFile() {
if [[ ! -f  $2 ]]; then
    echo "... $1 ($2) does not exist !"
    exit 1
fi
}
all_chromo=( "chr"{1..22} )
#all_chromo=( "chr1" )

binSignalFolder="/mnt/ed4/marie/scripts/EZH2_final_MAPQ/29_05_20kb_GSE63525/GM12878/TopDom"

all_peak_folders=( "BROADPEAKS" "NARROWPEAKS")
all_peak_folders=( "BROADPEAKS")


#all_folds=$(	IFS=, ; echo "${all_peak_folders[*]}")
all_folds="$( printf "_%s" "${all_peak_folders[@]}" )"

outFolder="PREP_DATA_FILES${all_folds}"
outFolder_final="FINAL_DATA_FILES${all_folds}"
cmd="mkdir -p $outFolder"
runCMD "$cmd"

cmd="mkdir -p $outFolder_final"
runCMD "$cmd"


for chromo in "${all_chromo[@]}"; do

	in_binSignalFile="$binSignalFolder/GM12878_${chromo}_20000_aggregCounts_ICE.txt.binSignal"
	
	if [[ ! -f $in_binSignalFile ]]; then
		echo "in_binSignalFile = $in_binSignalFile does not exist"
		exit 1
	fi

	out_binCoordFile="$outFolder/GM12878_${chromo}_binCoord.bed"
	
	out_binScoreFile="$outFolder/GM12878_${chromo}_binScore.bed"

	# prepare the final table -> do it in R to aggregate the same protein columns !
	
	bin_scoreFile="$out_binScoreFile"

	signalValuesFile="$outFolder/GM12878_${chromo}_allSignal_noheader.txt"
	cmd="paste $outFolder/EN*_${chromo}_binSumValue.bed > $signalValuesFile" 
	runCMD "$cmd"
	checkFile signalValuesFile $signalValuesFile

	signalValuesHeader="$outFolder/GM12878_${chromo}_allSignal_header.txt"
	cmd="ls $outFolder/EN*_${chromo}_binSumValue.bed | xargs -n 1 basename |sed 's/-human_chr1_binSumValue.bed//g' | paste -sd\"\t\" > $signalValuesHeader"
	runCMD "$cmd"
	checkFile signalValuesHeader $signalValuesHeader
	
	signalValuesFinalFile="$outFolder/GM12878_${chromo}_allSignalFinal.txt"
	cmd="cat $signalValuesHeader $signalValuesFile > $signalValuesFinalFile"
	runCMD "$cmd"
	checkFile signalValuesFinalFile $signalValuesFinalFile

	binScoreHeader="$outFolder/GM12878_${chromo}_binScore_header.txt"
	cmd="echo binScore > $binScoreHeader"
	runCMD "$cmd"	
	checkFile binScoreHeader $binScoreHeader

	binScoreFinalFile="$outFolder/GM12878_${chromo}_binScoreFinal.txt"
	cmd="cat $binScoreHeader $bin_scoreFile > $binScoreFinalFile"
	runCMD "$cmd"
	checkFile binScoreFinalFile $binScoreFinalFile

	final_file="$outFolder_final/GM12878_${chromo}_final.txt"
	cmd="paste $binScoreFinalFile $signalValuesFinalFile > $final_file"
	runCMD "$cmd"
	checkFile final_file $final_file
	
	
break #<<<<<<

done # end-iterating over chromo


exit 0


# map computes the sum of the 5th column (the score field for BED format) for all intervals in B that overlap each interval in A.
# 
# $ cat a.bed
# chr1        10      20      a1      1       +
# chr1        50      60      a2      2       -
# chr1        80      90      a3      3       -
# 
# $ cat b.bed
# chr1        12      14      b1      2       +
# chr1        13      15      b2      5       -
# chr1        16      18      b3      5       +
# 
# bedtools map -a a.bed -b b.bed
# chr1        10      20      a1      1       +       12
# 
# 
# bedtools map -a bin_coord.bed -b chip.bed
