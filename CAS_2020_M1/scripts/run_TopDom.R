
# launch with Rscript run_TopDom.R -i <input_file> -s <output_signal_file> -d <output_domain_file> -w <window_size>

library(TopDom)


#  command = "Rscript " + script + " -i " + count_file + " -s " + signalFile + " -d " + domainFile + " -w " + td_ws

library(optparse,verbose=F, quietly=T)

option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="path to input count matrix file", metavar="character"),
  make_option(c("-o", "--out_prefix"), type="character", default=NULL,
              help="prefix for the output files", metavar="character"),                          
  make_option(c("-w", "--window_size"), type="character", default=NULL,
              help="window size for TopDom", metavar="character")
);


opt_parser <- OptionParser(option_list=option_list);
opt <- parse_args(opt_parser);

if(is.null(opt$input) | is.null(opt$window_size) | is.null(opt$out_prefix) ) {
	stop("Error - missing input argument ! Should be launch with: \n")
}

inputFile <- opt$input
outPrefix <- opt$out_prefix
window_size <- opt$window_size


outFold <- dirname(outPrefix)
system(paste0("mkdir -p ", outPrefix))


TopDom(matrix.file=inputFile, window.size=window_size, outFile = outPrefix) 

