startTime <- Sys.time()
options(scipen = 100)

library(foreach)
library(doMC)

# Rscript aggreg_cols.R <input_file> [<output_file>]
# Rscript aggreg_cols.R FINAL_DATA_FILES/GM12878_chr1_final.txt
# Rscript aggreg_cols.R FINAL_DATA_FILES/GM12878_chr1_final.txt FINAL_AGG_DATA_FILES/GM12878_chr1_final_agg.txt

cat("> START aggreg_cols.R")

SSHFS <- FALSE
registerDoMC(ifelse(SSHFS, 2, 40))
setDir <- ifelse(SSHFS, "/media/electron", "")

inputDT_file <- "FINAL_DATA_FILES_BROADPEAKS/GM12878_chr1_final.txt"

args <- commandArgs(trailingOnly = TRUE)
inputDT_file <- args[1]
if(length(args) == 2){
  outputDT_file <- args[2]
} else {
  outputDT_file <- gsub("_final.txt$", "_final_agg.txt", inputDT_file)
}
stopifnot(file.exists(inputDT_file))
dir.create(dirname(outputDT_file))

aggregFunc <- "rowSums"  # columns are standardized before NN input
txt <- paste0("... aggregation function: ", aggregFunc, "\n")
stopifnot(is.function(eval(parse(text=aggregFunc))))

inputDT <- read.delim(inputDT_file, header=T, stringsAsFactors = FALSE)
inputDT[1:5,1:5]
dim(inputDT)
stopifnot(!is.na(inputDT))

chip_names <- gsub("^EN.+_(.+)$", "\\1", colnames(inputDT)[-1])
chip_names <- gsub("^EN.+?_(.+)$", "\\1", colnames(inputDT)[-1])
head(chip_names)

to_agg_names <- chip_names[duplicated(chip_names)]
txt <- paste0("... # to aggregate: ", length(to_agg_names), "\n")
cat(txt)

prot_names <- unique(chip_names)

prot = prot_names[1]

outputDT_prot <- foreach(prot = prot_names, .combine='cbind') %dopar% {
  
  prot_cols <- grep(paste0("^EN.+_", prot, "$"),  colnames(inputDT))
  
  if(prot %in% to_agg_names){
    stopifnot(length(prot_cols) > 1)
    outDT <- inputDT[, prot_cols]
    new_col_name <- paste0(paste0(gsub(paste0("_", prot, "$"), "",  colnames(outDT)), collapse="_"), "_", prot)
    out_col <- data.frame(x = do.call(aggregFunc, list(outDT)), stringsAsFactors = FALSE)
    colnames(out_col) <- new_col_name
  } else {
    stopifnot(length(prot_cols) == 1)
    out_col <- inputDT[,prot_cols, drop=F]
  }
  out_col
}
outputDT <- cbind(inputDT[,1,drop=F], outputDT_prot)
stopifnot(!is.na(outputDT))
stopifnot(ncol(outputDT) == (length(prot_names) + 1))
stopifnot(nrow(outputDT) == nrow(inputDT))


write.table(outputDT, sep="\t", quote=F, file=outputDT_file, col.names=TRUE, row.names=FALSE)
cat(paste0("... written: ", outputDT_file, "\n"))

cat(paste0("sum(outputDT[,1] == 1) = ", sum(outputDT[,1] == 1), "\n"))
cat(paste0("sum(rowSums(outputDT[,-1]) == 0) = ",sum(rowSums(outputDT[,-1]) == 0), "\n"))
cat(paste0("sum(outputDT[,1] == 1 & rowSums(outputDT[,-1]) == 0) = ", sum(outputDT[,1] == 1 & rowSums(outputDT[,-1]) == 0), "\n"))
cat(paste0("sum(outputDT[,1] == 1 | rowSums(outputDT[,-1]) == 0) = ", sum(outputDT[,1] == 1 | rowSums(outputDT[,-1]) == 0), "\n"))

outputDT[1:5,1:5]

txt <- paste0("... # to aggregate: ", length(to_agg_names), "\n")
cat(txt)
cat(paste0("... dim(inputDT) = ", paste0(dim(inputDT), collapse = " x "), "\n"))
cat(paste0("... dim(outputDT) = ", paste0(dim(outputDT), collapse = " x "), "\n"))

outFile <- gsub("_final_agg.txt", "_chip_density.svg", outputDT_file)
svg(outFile, height=7, width=10)
plot(density(rowSums(outputDT[,-1])))
foo <- dev.off()
cat(paste0("... written: ", outFile, "\n"))

outFile <- gsub("_final_agg.txt", "_score_density.svg", outputDT_file)
svg(outFile, height=7, width=10)
plot(density(outputDT[,1] ))
foo <- dev.off()
cat(paste0("... written: ", outFile, "\n"))

outFile <- gsub("_final_agg.txt", "_noOneScore_density.svg", outputDT_file)
svg(outFile, height=7, width=10)
plot(density(outputDT[,1][outputDT[,1] < 1] ))
foo <- dev.off()
cat(paste0("... written: ", outFile, "\n"))

outFile <- gsub("_final_agg.txt", "_noZeroChip_density.svg", outputDT_file)
svg(outFile, height=7, width=10)
plot(density(rowSums(outputDT)[rowSums(outputDT[,-1]) > 0]))
foo <- dev.off()
cat(paste0("... written: ", outFile, "\n"))

outFile <- gsub("_final_agg.txt", "_noZeroChip_noOneScore_density.svg", outputDT_file)
svg(outFile, height=7, width=10)
plot(density(rowSums(outputDT)[rowSums(outputDT[,-1]) > 0 & outputDT[,1] < 1]))
foo <- dev.off()
cat(paste0("... written: ", outFile, "\n"))

cat(paste0("sum(outputDT[,1] == 1) = ", sum(outputDT[,1] == 1), "\n"))
cat(paste0("sum(rowSums(outputDT[,-1]) == 0) = ",sum(rowSums(outputDT[,-1]) == 0), "\n"))
cat(paste0("sum(outputDT[,1] == 1 & rowSums(outputDT[,-1]) == 0) = ", sum(outputDT[,1] == 1 & rowSums(outputDT[,-1]) == 0), "\n"))
cat(paste0("sum(outputDT[,1] == 1 | rowSums(outputDT[,-1]) == 0) = ", sum(outputDT[,1] == 1 | rowSums(outputDT[,-1]) == 0), "\n"))


stopifnot(outputDT[,1] <= 1)

filterRows <- (outputDT[,1] == 1 | rowSums(outputDT[,-1]) == 0)

filteroutputDT_file <- gsub("_final_agg.txt", "_final_agg_fltrd.txt", outputDT_file)

filterDT <- outputDT[!filterRows, ]
write.table(filterDT, sep="\t", quote=F, file=filteroutputDT_file, col.names=TRUE, row.names=FALSE)
cat(paste0("... written: ", filteroutputDT_file, "\n"))

txt <- paste0("... # to aggregate: ", length(to_agg_names), "\n")
cat(txt)
cat(paste0("... dim(inputDT) = ", paste0(dim(inputDT), collapse = " x "), "\n"))
cat(paste0("... dim(outputDT) = ", paste0(dim(outputDT), collapse = " x "), "\n"))
cat(paste0("... dim(filterDT) = ", paste0(dim(filterDT), collapse = " x "), "\n"))

######################################################################################

cat("*** DONE\n")
cat(paste0(startTime, "\n", Sys.time(), "\n"))

