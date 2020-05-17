#####################################################################
############################# Hi-C data #############################
#####################################################################

***** STEP1: download the data with juicer

-> To do for each chromosome:

hic_source="https://hicfiles.s3.amazonaws.com/hiseq/GM12878/in-situ/combined.hic"
jar_file="<path to>/juicer_tools_1.13.02.jar"
chr="chr21"
norm_meth="KR"
resol=20000
out_file="GM12878_${chromo}_${resol}kb.hic"

java -jar ${jar_file} dump observed $norm_meth ${hic_source} ${chr} ${chr} BP ${resol} ${out_file}


***** STEP 2: convert from .hic to the format needed for TopDom

-> cf. convert_hic2TopDom.R


***** STEP 3: run TopDom

-> cf. run_TopDom.R 


***** STEP 4: extract the list of genomic bins and retrieve TopDom boundary scores

-> cf final_past_cmd.sh


#####################################################################
########################### ChIP-seq data ###########################
#####################################################################

***** STEP 1: download the data from ENCODE:

(NB: narrow_peaks have not been used so far for the analyses)

-> Download the narrow peaks files:
https://www.encodeproject.org/search/?type=Experiment&assay_title=ChIP-seq&biosample_ontology.term_name=GM12878&biosample_ontology.classification=cell+line&files.file_type=bed+narrowPeak
(saved in narrow_peak_dld.txt)

-> Create a folder and download all the corresponding files
mkdir narrow_peaks
cd narrow_peaks
xargs -L 1 curl -O -L < ../narrow_peak_dld.txt

-> Do the same for the broad peaks files
https://www.encodeproject.org/search/?type=Experiment&assay_title=ChIP-seq&biosample_ontology.term_name=GM12878&biosample_ontology.classification=cell+line&files.file_type=bed+broadPeak
(saved in broad_peak_dld.txt)
mkdir broad_peaks
cd broad_peaks
xargs -L 1 curl -O -L < ../broad_peak_dld.txt

-> Format of the downloaded data (we are interested in  the 7th column):
(
    string chrom;        "Reference sequence chromosome or scaffold"
    uint   chromStart;   "Start position in chromosome"
    uint   chromEnd;     "End position in chromosome"
    string name;	 "Name given to a region (preferably unique). Use . if no name is assigned"
    uint   score;        "Indicates how dark the peak will be displayed in the browser (0-1000) "
    char[1]  strand;     "+ or - or . for unknown"
    float  signalValue;  "Measurement of average enrichment for the region"
    float  pValue;       "Statistical significance of signal value (-log10). Set to -1 if not used."
    float  qValue;       "Statistical significance with multiple-test correction applied (FDR -log10). Set to -1 if not used."
    int   peak;         "Point-source called for this peak; 0-based offset from chromStart. Set to -1 if no point-source called."
)

-> rename the files so that the name of the epigenetic mark is present in the file names
(this will serve for aggregating the signal values in third step)
(cf. rename_file.pl)

***** STEP 2: map the signal values to the genomic bins

-> cf. first part of aggreg_hist_signals.sh

***** STEP 3: aggregate the signal values from the same marks but different experiments

Rscript aggreg_cols.R <input_file> [<output_file>] (cf. aggreg_cols.sh)

***** STEP 4: aggregate the signal values to each genomic bin (the genominc bins should be prepared separately from TopDom output, cf. previous section)

-> cf. second part of aggreg_hist_signals.sh


############################################################################################
########################### Final merging ChIP-seq and Hi-C data ###########################
############################################################################################

For each genomic bin, now is prepared the boundary score and the signal values.
Do the merging based on genomic bin.

-> cf. last part of aggreg_hist_signals.sh





