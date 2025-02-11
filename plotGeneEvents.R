require(tidyverse)
require(rtracklayer)
require(circlize)

genes="ICOS|EPDR1|LINGO2|SYPL1"
genes=strsplit(genes,"\\|")[[1]]


for(gene in genes) {

    geneRe=gene

    xx=readxl::read_xlsx("Proj_KEJ.S01__SV_Delly_TCellGeneEvents.xlsx") %>% filter(grepl(geneRe,query.startfeature) | grepl(geneRe,query.endfeature)) %>% select(SID,1:15) %>% mutate(weight=SplitReadCount+PairEndCount)

    genes=c(gsub("\\(.*","",xx$query.startfeature),gsub("\\(.*","",xx$query.endfeature))

    bedA=xx %>% select(chr=query.chr,mid=query.start) %>% mutate(chr=paste0("chr",chr))
    bedB=xx %>% select(chr=query.chr2,mid=query.end) %>% mutate(chr=paste0("chr",chr))

    gA=xx %>% select(chr=query.chr,start=query.start,genes=query.startfeature) %>% mutate(end=start+1) %>% select(chr,start,end,genes) %>% separate_rows(genes,sep=",") %>% filter(grepl("^TR",genes)|grepl(geneRe,genes)) %>% mutate(genes=gsub("\\(.*","",genes))
    gB=xx %>% select(chr=query.chr2,start=query.end,genes=query.endfeature) %>% mutate(end=start+1) %>% select(chr,start,end,genes) %>% separate_rows(genes,sep=",") %>% filter(grepl("^TR",genes)|grepl(geneRe,genes)) %>% mutate(genes=gsub("\\(.*","",genes))

    gannote=bind_rows(gA,gB) %>% mutate(chr=paste0("chr",chr))

    # gB=bedB %>% mutate(start=mid-1,end=mid) %>% select(-mid)
    # gA=bedA %>% mutate(start=mid-1,end=mid) %>% select(-mid)
    # gannote=bind_rows(gA,gB)


    pdf(file=cc("circosB",gene,".pdf"),width=11,height=11)

    circos.par("track.height" = 0.1, cell.padding = c(0, 0, 0, 0))
    circos.initializeWithIdeogram(plotType=c("labels", "axis"))
    circos.genomicLabels(gannote,labels.column=4,side="outside")
    circos.genomicIdeogram()

    clrs=RColorBrewer::brewer.pal(8,"Dark2")[1:nrow(bedA)]
    colors=add_transparency(clrs,.5)
    circos.genomicLink(bedA,bedB,lwd=sqrt(xx$weight),col = colors,  border = NA)
    title(gsub(".*__","",xx$SID[1]))

    dev.off()


}