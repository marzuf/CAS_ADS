# Rscript convert_hic2TopDom.R <infile> <outputfile> <chromo> <binSize> [<chromoSize>]

# Rscript convert_hic2TopDom.R hicfoo.hic hicfoo.hic_converted chr21 50000
# Rscript convert_hic2TopDom.R hicfoo.hic hicfoo.hic_converted2 chr21 50000 220000

options(scipen=100)

require(Matrix)

args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) >= 4)
inFile <- args[1]
outFile <- args[2]
chromo <- args[3]
binSize <- as.numeric(args[4])
stopifnot(!is.na(binSize))
chrSize <- args[5]
if(!is.na(chrSize)) {
  chrSize <- as.numeric(chrSize)
  stopifnot(!is.na(chrSize))
}

dir.create(dirname(outFile), recursive = TRUE)

in_dt <- read.table(inFile, stringsAsFactors = FALSE, header=FALSE)
stopifnot(ncol(in_dt) == 3)
colnames(in_dt) <- c("binA", "binB", "count")
stopifnot(is.numeric(in_dt$count))

stopifnot(in_dt$binB >= in_dt$binA)

# 50000/50000 -> 1, but should be 2nd bin, the first is zero
in_dt$binA_resc <- in_dt$binA/binSize+1 # + 1 1-based, try e.g. sparseMatrix(i = 1, j = 1, x=1, dims=c(2,2))
in_dt$binB_resc <- in_dt$binB/binSize+1
stopifnot(in_dt$binA_resc %% 1 == 0)
stopifnot(in_dt$binB_resc %% 1 == 0)

if(is.na(chrSize)) {
  chrSize_resc <- max(c(in_dt$binA_resc, in_dt$binB_resc)) 
} else {
  chrSize_resc <- ceiling(chrSize/binSize)+1 # e.g. if 45000 -> should be 50000
  stopifnot(chrSize_resc >= c(in_dt$binA_resc, in_dt$binB_resc))
}

countMatrix <- sparseMatrix(i = in_dt$binA_resc, 
             j = in_dt$binB_resc, 
             x = in_dt$count,
             dims=c(chrSize_resc, chrSize_resc)) 
count_dt <- as.data.frame(as.matrix(forceSymmetric(countMatrix)))

stopifnot(count_dt[1,2] == count_dt[2,1])
stopifnot(count_dt[5,4] == count_dt[4,5])

bin_dt <- data.frame(
  chromo = chromo,
  binStart = seq(from=0, by = binSize, length.out=nrow(count_dt)),
  binEnd = seq(from=binSize, by = binSize, length.out=nrow(count_dt)),
  stringsAsFactors = FALSE
)

out_dt <- cbind(bin_dt, count_dt)

stopifnot(nrow(out_dt) == ncol(out_dt) -3)

write.table(out_dt, sep="\t", file=outFile, quote=F, col.names=FALSE, row.names = FALSE)
cat(paste0("... written: ", outFile, "\n"))


