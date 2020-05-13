use strict;
use warnings;

my $startTime = localtime;


#my $bedFolder = "narrow_peaks";
my $bedFolder = "narrow_peaks";


my $metadataFile;

$metadataFile="$bedFolder"."/"."metadata.tsv";

my @all_bed_files=`ls $bedFolder`;
#my @all_bed_files=`ls -d $bedFolder/*`;

my $access;
my $grep_access;

my $cmd;

my $gzpd;

my $prot_access;

my $newfile;

my $i=0;

foreach my $bedfile (@all_bed_files){
	print $bedfile."\n";
	
	my $x=`ls -1 $bedFolder | wc -l`;
	print $x."\n";
	
	$bedfile =~ s/^\s+|\s+$//g;


	next if ($bedfile =~ /human/) ;
	
	if ($bedfile =~ /(^EN.+)\.bed/) {
		$access = "$1";
	} else {
		exit 1;
	}
	print $access."\n";

	if ($bedfile =~ /(^EN.+)\.bed.gz/) {
		$gzpd = 1;
		$cmd="gunzip $bedFolder/$bedfile";
		`$cmd`;
		print $cmd."\n";

		
		$bedfile =~ s/\.bed\.gz$/.bed/;
		
	} else {
		$gzpd = 0;
	}
	print $access."\n";




	
	$cmd="grep $access $metadataFile | cut -f13";
	print $cmd."\n";

	$prot_access = `$cmd`;
	$prot_access =~ s/^\s+|\s+$//g;

	print $prot_access."\n";
	
	$cmd="gzip $bedFolder/$bedfile";
	print $cmd."\n";
	`$cmd`;
	$bedfile .= ".gz";
	
	$newfile="${access}_${prot_access}.bed.gz";
	
	if (not $bedfile eq $newfile) {
		$cmd="mv $bedFolder/$bedfile $bedFolder/$newfile";
		print $cmd."\n";
		`$cmd`;		
	}
	
	my $y=`ls -1 $bedFolder | wc -l`;
	print $y."\n";
	
	#exit 1 if $i == 3;

	$i++;
}     

exit 0;

# my $inFile = "ensembl_data_out.txt";
# 
# my $outFileSyno = "ENSEMBL_out_syno.txt";
# my $outFileLoc = "ENSEMBL_out_loc.txt";
# my $outFileEnsembl = "ENSEMBL_out_entrez.txt";
# 
# system("rm -f $outFileSyno");
# system("rm -f $outFileLoc");
# system("rm -f $outFileEnsembl");
# open my $outSyno, ">>", $outFileSyno;
# open my $outLoc, ">>", $outFileLoc;
# open my $outEns, ">>", $outFileEnsembl;
# 
# printf $outSyno "entrezID\tsymbol\tsyno\tchromo\n";
# printf $outLoc "entrezID\tchromo\tAnnotRelease\tAssemblyAcc\tstart\tend\n";
# printf $outEns "ensemblID\tentrezID\n";
# 
# # esearch -db gene -query "(1[id])" |  efetch -format docsum |  xtract -pattern DocumentSummary -sep "\t" -element Id Name OtherAliases ChrLoc -block LocationHistType -element AnnotationRelease AssemblyAccVer ChrStart ChrStop
# #7157	TP53	BCC7, LFS1, P53, TRP53	17	108	GCF_000001405.33	7687549	7668401	108	GCF_000306695.2	7600002	7580865	107	GCF_000001405.28	7687549	7668401	107	GCF_000306695.2	7600002	7580865	106	GCF_000001405.26	7687549	7668401	106	GCF_000002125.1	7484282	7465168	106	GCF_000306695.2	7600002	7580865	105	GCF_000001405.25	7590867	7571719	105	GCF_000002125.1	7484282	7465168	105	GCF_000306695.2	7600002	7580865	104	GCF_000001405.22	7590867	7571719	104	GCF_000002125.1	7484282	7465168	104	GCF_000306695.1	7580073	7560922	103	GCF_000001405.21	7590867	7571719	103	GCF_000002125.1	7484282	7465168	37.3	GCF_000001405.17	7590862	7571719	37.3	GCF_000002125.1	7484277	7465168	37.2	GCF_000001405.14	7590862	7571719	37.2	GCF_000002115.2	7617223	7598098	37.2	GCF_000002125.1	7484277	7465168	37.1	GCF_000001405.13	7590862	7571719	37.1	GCF_000002115.2	7617223	7598098	37.1	GCF_000002125.1	7484277	7465168	36.3	GCF_000001405.12	7531641	7512444	36.3	GCF_000002115.2	7617277	7598098	36.3	GCF_000002125.1	7484331	7465168
# open my $fh, "<", $inFile or die ;
# 
# while(my $line = <$fh>) {