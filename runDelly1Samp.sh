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
BASE=$(basename $TUMOR | sed 's/.bam//' | sed 's/.smap*//' )

echo $TUMOR
echo $BASE

GENOME_BUILD=$($SDIR/bin/getGenomeBuildBAM.sh $TUMOR)

if [ "$GENOME_BUILD" == "b37" ]; then
    GENOME=/juno/bic/depot/assemblies/H.sapiens/b37/b37.fasta
    EXCL=$SDIR/rsrc/delly/human.b37.excl.tsv
elif [ "$GENOME_BUILD" == "GRCh38" ]; then
    GENOME=/juno/bic/depot/assemblies/H.sapiens/GRCh38_1kg/GRCh38_full_analysis_set_plus_decoy_hla.fa
    EXCL=$SDIR/rsrc/delly/human.hg38.excl.tsv
else
    echo "Unknown genome build: $GENOME_BUILD"
    exit 1
fi

DELLY=$(ls $SDIR/bin/delly_*linux_x86_* | sort -V | tail -1)

ODIR=out/delly/$BASE

mkdir -p $ODIR

$DELLY \
    call \
    -x $EXCL \
    -g $GENOME \
    -o ${ODIR}/${BASE}.bcf \
    $TUMOR

bcftools view ${ODIR}/${BASE}.bcf >${ODIR}/${BASE}.vcf

cat <<-EOF > $ODIR/${BASE}.run.log
SDIR: $SDIR
GENOME_BUILD: $GENOME_BUILD
GENOME: $GENOME
EXCL: $EXCL
TUMOR: $TUMOR
ODIR: $ODIR
DELLY: $DELLY

BCFTOOLS: $(bcftools --version | head -1)

Script: $0 $*

$DELLY \
    call \
    -x $EXCL \
    -g $GENOME \
    -o ${ODIR}/${BASE}.bcf \
    $TUMOR

bcftools view ${ODIR}/${BASE}.bcf >${ODIR}/${BASE}.vcf

EOF
