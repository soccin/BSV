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

SAMPLETBL="sampleIDs.txt"

module load bcftools

NORMAL=$1
TUMOR=$2
BASE=$(basename $TUMOR | sed 's/.bam//' | sed 's/_indel.*s_/___s_/')___$(basename $NORMAL | sed 's/.bam//' | sed 's/Proj.*_s_/s_/')

if [ ! -e $SAMPLETBL ]; then
    echo
    echo "  Missing sampleIDs.txt file"
    echo "  AutoGenerating one"
    echo

    SAMPLETBL=sampleTbl__${BASE}.txt

    echo

    getBAMSampleTag $NORMAL
    echo -e "$ST\tcontrol" | tee sampleTbl__${BASE}.txt
    getBAMSampleTag $TUMOR
    echo -e "$ST\ttumor" | tee -a sampleTbl__${BASE}.txt
    echo

fi


echo "========================"

echo $SAMPLETBL

echo $NORMAL
echo $TUMOR
echo $BASE

echo

GENOME=/juno/depot/assemblies/M.musculus/mm10/mm10.fasta
EXCL=$SDIR/delly/excludeTemplates/mouse.mm10.excl.tsv

$SDIR/delly_v0.8.7_linux_x86_64bit \
    call \
    -x $EXCL \
    -g $GENOME \
    -o ${BASE}.bcf \
    $TUMOR $NORMAL

$SDIR/delly_v0.8.7_linux_x86_64bit \
    filter \
    -f somatic \
    -o ${BASE}___FILTER.bcf \
    -s $SAMPLETBL \
    ${BASE}.bcf

bcftools view ${BASE}___FILTER.bcf >${BASE}___FILTER.vcf

