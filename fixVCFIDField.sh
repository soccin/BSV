#!/bin/bash

VCF=$1

BASE=${VCF/.vcf.gz/}

OVCF=${BASE}.uuid.vcf

SID=$(gzcat $VCF | fgrep "#CHROM" | cut -f10 | sed 's/dna//')

bcftools annotate --set-id 'DL:'${SID}':%ID' $VCF >$OVCF

bgzip $OVCF
tabix -p vcf ${OVCF}.gz
