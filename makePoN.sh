#!/bin/bash

#find out | fgrep .uuid | fgrep -v .tbi | sort -V | xargs -n 2 | awk '{print $2}' >normals
#find out | fgrep .uuid | fgrep -v .tbi | sort -V | xargs -n 2 | awk '{print $1}' >tumors

bcftools merge $(cat normals) \
    | bcftools +fill-tags - -o pon.merge.vcf.gz -- -t AF,AC,AN,NS

tabix -p vcf pon.merge.vcf.gz

