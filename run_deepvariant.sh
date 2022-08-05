#!/bin/bash

## Here we're running the deepvariant caller
## doesn't work directly on cram files so had to convert again from cram to bam.
## also the paths are a bit confusing but this should work if the crams/bams and
## reference fa+fai are in the current working directory

# test runs okay
skip(){
BIN_VERSION="1.4.0"
udocker run \
 -v "/home/ziemannm/lhon_wes/variants":"/input" \
  -v "/home/ziemannm/lhon_wes/variants/output:/output" \
  google/deepvariant:"${BIN_VERSION}" \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type=WES \
  --ref=/input/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa \
  --reads=/input/test.bam \
  --output_vcf=/output/test.vcf \
  --output_gvcf=/output/test.gvcf \
  --num_shards=1 \
  --logging_dir=/output/logs --dry_run=false
}



QUALIMAP=../sw/qualimap_v2.2.1/qualimap
SAMTOOLS=../sw/samtools-1.15.1/samtools

for CRAM in test.cram ; do
  BAM=$(echo $CRAM | sed 's/.cram/.bam/')
  BASE=$(echo $CRAM | cut -d '_' -f1 )
  $SAMTOOLS view -@20 -b $CRAM > $BAM
  $SAMTOOLS index $BAM

  BIN_VERSION="1.4.0"
  udocker run \
    -v "/home/ziemannm/lhon_wes/variants":"/input" \
    -v "/home/ziemannm/lhon_wes/variants/output:/output" \
    google/deepvariant:"${BIN_VERSION}" \
    /opt/deepvariant/bin/run_deepvariant \
    --model_type=WES \
    --ref=/input/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa \
    --reads=/input/${BASE}.bam \
    --output_vcf=/output/${BASE}.vcf \
    --output_gvcf=/output/${BASE}.gvcf \
    --num_shards=32 \
    --logging_dir=/output/logs --dry_run=false

  rm $BAM
done
