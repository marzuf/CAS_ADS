#!/usr/bin/bash

# workflow

# first rename the bed files so that they contain accession and protein name

# -> for each chromo
# take the file from GM12878 with TAD coordinates
# extract TAD coordinates as BED format
# for each of peak file available -> sum over the TAD coordinates


runCMD() {
  echo "> $1"
  eval $1
}

checkFile() {
if [[ ! -f  $2 ]]; then
    echo "... $1 ($2) does not exist !"
    exit 1
fi
}
#all_chromo=( "chr" 1..22 )

all_chromo=( "chr1" )

binSignalFolder="/mnt/ed4/marie/scripts/EZH2_final_MAPQ/29_05_20kb_GSE63525/GM12878/TopDom"

outFolder="PREP_DATA_FILES"
outFolder_final="FINAL_DATA_FILES"
mkdir -p $outFolder
mkdir -p $outFolder_final

#all_peak_folders=( "broad_peaks" "narrow_peaks" )

all_peak_folders=( "broad_peaks" )


for chromo in "${all_chromo[@]}"; do

	in_binSignalFile="$binSignalFolder/GM12878_${chromo}_20000_aggregCounts_ICE.txt.binSignal"
	
	if [[ ! -f $in_binSignalFile ]]; then
		echo "in_binSignalFile = $in_binSignalFile does not exist"
		exit 1
	fi

	out_binCoordFile="$outFolder/GM12878_${chromo}_binCoord.bed"
	
	out_binScoreFile="$outFolder/GM12878_${chromo}_binScore.bed"

	# prepare the bin coordinates
	cmd="cut -f2-4 $in_binSignalFile | tail -n+2 > $out_binCoordFile"
	runCMD "$cmd"
	checkFile out_binCoordFile $out_binCoordFile


	# prepare the bin score
	cmd="cut -f7 $in_binSignalFile | tail -n+2 > $out_binScoreFile"
	runCMD "$cmd"
	checkFile out_binScoreFile $out_binScoreFile

	# iterate over all protein files
	

	
# 	for peakFolder in "${all_peak_folders[@]}"; do
# 	
# 		echo "... start $peakFolder"
# 	
# 		if [[ ! -d $peakFolder ]]; then
# 			echo "peakFolder = $peakFolder does not exist"
# 			exit 1
# 		fi	
# 	
# 		all_peak_files=$( (ls $peakFolder/EN*.bed.gz) )
# 		
# 		for peak_file in ${all_peak_files[@]}; do
# 			cmd="gunzip $peak_file"
# 			runCMD "$cmd"
# 			
# 			tmp_file=`basename $peak_file .gz`
# 			unzpd_peak_file=$peakFolder/$tmp_file
# 			checkFile unzpd_peak_file $unzpd_peak_file
# 			
# 			tmp_file2=`basename $peak_file .bed.gz`
# 			
# 			chr_peak_file="$peakFolder/${tmp_file2}_${chromo}.bed"
# 
# 			
# 			
#             cmd="grep \"${chromo}\\s\" $unzpd_peak_file | cut -f1-4,7 > $chr_peak_file"
# 			runCMD "$cmd"
# 
# 			checkFile chr_peak_file $chr_peak_file
# 			
# 			
# 			cmd="gzip $unzpd_peak_file"
# 			runCMD "$cmd"
# 			checkFile peak_file $peak_file
# 
#   
# 			tmp_name=`basename $peak_file .bed.gz`
# 			out_histValueFile_tmp="$outFolder/${tmp_name}_${chromo}_binSumValue.bed_tmp"
# 		
# 			cmd="bedtools map -a $out_binCoordFile -b $chr_peak_file > $out_histValueFile_tmp"
# 			echo $cmd
# 			runCMD "$cmd"
# 			checkFile out_histValueFile_tmp $out_histValueFile_tmp
# 			
# 			tmp_name2=`basename $out_histValueFile_tmp _tmp`
# 			out_histValueFile="$outFolder/${tmp_name2}"
# 
# 
# 
# 			cmd="cut -f4 $out_histValueFile_tmp | sed 's/^\.$/0/g' > $out_histValueFile"  # a dot is added where there is no overlap -> replace with 0
# 			runCMD "$cmd"
# 			checkFile out_histValueFile $out_histValueFile
# 
# 
# 		done # end-iterating over peak file
# 	
# 	
# 	done # end-iterating over peak type
	
	
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
		exit 1	

	


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
