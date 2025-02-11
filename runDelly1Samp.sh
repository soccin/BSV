#!/bin/bash

getBAMSampleTag() {
    ST=$(samtools view -H $1 \
            | fgrep "@RG" \
            | tr '\t' '\n' \
            | egrep "^SM:" \
            | sed 's/^SM://' )
}

set -e

SDIR="$( cd "$( dirname "$0" )" && pwd )"

module load bcftools

TUMOR=$1
BASE=$(basename $TUMOR | sed 's/.bam//' | sed 's/___MD.*//')

echo $TUMOR
echo $BASE

GENOME=/juno/depot/assemblies/H.sapiens/b37/b37.fasta
EXCL=$SDIR/delly/excludeTemplates/human.b37.excl.tsv

DELLY=delly_v1.2.6_linux_x86_64bit

$SDIR/bin/$DELLY \
    call \
    -x $EXCL \
    -g $GENOME \
    -o ${BASE}.bcf \
    $TUMOR

bcftools view ${BASE}.bcf >${BASE}___FILTER.vcf

