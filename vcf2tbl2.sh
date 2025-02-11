#!/bin/bash
VCF=$1
BASE=${VCF/.vcf.gz/}
>&2 echo $BASE

QUERY="%ID\t%FILTER\t%SVTYPE\t%PE\t%SR\t[%GT]\t[%FT]\t[%DR]\t[%DV]\t[%RR]\t[%RV]\t%MAPQ\t%SRMAPQ\t%CONSENSUS"

(
    echo -e $(echo $QUERY | tr -d '[%\[\]]');
    bcftools query -f $QUERY $VCF
) \
    | fgrep -v LowQual \
    > ${BASE}.pass.all.tbl0

# ./bin/sansa annotate \
#     -g rsrc/Homo_sapiens.GRCh37.87.gtf.gz \
#     -a ${BASE}.gene.bcf \
#     -o ${BASE}.gene.query.tsv.gz \
#     $VCF

# rm ${BASE}.gene.bcf

# ./bin/sansa annotate \
#     -d pon.merge.vcf.gz \
#     -a ${BASE}.pon.bcf \
#     -o ${BASE}.pon.query.tsv.gz \
#     $VCF

# QUERY2="%ANNOID\t%AF\t%AC\t%NS\t%AN\t%ID\t%FILTER"

# (
#     echo -e $(echo $QUERY2 | tr -d '[%\[\]]');
#     bcftools query -f $QUERY2 ${BASE}.pon.bcf
# ) > ${BASE}.pon.tbl0

# rm ${BASE}.pon.bcf.csi
# rm ${BASE}.pon.bcf

