https://www.encodeproject.org/search/?type=Experiment&assay_title=ChIP-seq&biosample_ontology.term_name=GM12878&biosample_ontology.classification=cell+line&files.file_type=bed+narrowPeak
> Download -> narrow_peak_dld.txt
cd narrow_peaks
xargs -L 1 curl -O -L < ../narrow_peak_dld.txt


https://www.encodeproject.org/search/?type=Experiment&assay_title=ChIP-seq&biosample_ontology.term_name=GM12878&biosample_ontology.classification=cell+line&files.file_type=bed+broadPeak
> Download -> broad_peak_dld.txt
cd broad_peaks
xargs -L 1 curl -O -L < ../broad_peak_dld.txt


table narrowPeak
"BED6+4 Peaks of signal enrichment based on pooled, normalized (interpreted) data."
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

wc -l narrow_peak_dld.txt 
1903 narrow_peak_dld.txt

wc -l broad_peak_dld.txt 
116 broad_peak_dld.txt

ls NARROWPEAKS/*bed.gz | wc -l
1903
ls BROADPEAKS/*bed.gz | wc -l
116
