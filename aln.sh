#!/bin/bash

# set some paths for software
SKEWER=../sw/skewer #0.2.2
BWA=../sw/bwa-mem2-2.2.1_x64-linux/bwa-mem2
SAMTOOLS=../sw/samtools-1.15.1/samtools

# set reference genome
REF=../ref/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa

# a test dataset
FQ1=test_R1_001.fastq.gz
FQ2=$(echo $FQ1 | sed 's/_R1_/_R2_/' )
BASE=$echo $FQ1 | cut -d '_' -f1)

$SKEWER -q 20 -t 16 $FQ1 $FQ2

FQ1T=$(echo $FQ1 | sed 's/.gz/-trimmed-pair1.fastq/')
FQ2T=$(echo $FQ1 | sed 's/.gz/-trimmed-pair2.fastq/')

CORES=$(echo $(nproc) | awk '{print$1/2}')
$BWA mem -t $CORES $REF ../$FQ1T $FQ2T \
  | $SAMTOOLS fixmate -O bam,level=1 -m - - \
  | $SAMTOOLS sort -u -@10 \
  | $SAMTOOLS markdup -@8 --reference $REF - $BASE.cram
rm $FQ1T $FQ2T

# variant calling with deepvariant or strelka2
# Barbitoff, Y.A., Abasov, R., Tvorogova, V.E. et al. Systematic benchmark of state-of-the-art variant calling pipelines identifies major factors affecting accuracy of coding sequence variant discovery. BMC Genomics 23, 155 (2022). https://doi.org/10.1186/s12864-022-08365-3

exit

BIN_VERSION="1.4.0"
udocker run \
  -v "YOUR_INPUT_DIR":"/input" \
  -v "YOUR_OUTPUT_DIR:/output" \
  google/deepvariant:"${BIN_VERSION}" \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type=WGS \ **Replace this string with exactly one of the following [WGS,WES,PACBIO,HYBRID_PACBIO_ILLUMINA]**
  --ref=/input/YOUR_REF \
  --reads=/input/YOUR_BAM \
  --output_vcf=/output/YOUR_OUTPUT_VCF \
  --output_gvcf=/output/YOUR_OUTPUT_GVCF \
  --num_shards=$(nproc) \ **This will use all your cores to run make_examples. Feel free to change.**
  --logging_dir=/output/logs \ **Optional. This saves the log output for each stage separately.
  --dry_run=false **Default is false. If set to true, commands will be printed out but not executed.
