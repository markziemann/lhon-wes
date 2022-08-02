#!/bin/bash
#alias fastqc='/home/ziemannm/lhon_wes/sw/FastQC/fastqc'
parallel -j10 /home/ziemannm/lhon_wes/sw/FastQC/fastqc -t5 ::: *gz
