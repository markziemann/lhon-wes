#!/bin/bash
wget http://ftp.ensembl.org/pub/release-107/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz
gunzip -f Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz
../sw/bwa-mem2-2.2.1_x64-linux/bwa-mem2 index Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa
