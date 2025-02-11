require(tidyverse)
require(rtracklayer)
require(circlize)
require(pals)

samps=scan("sampleSetA","")

xx=readxl::read_xlsx("Proj_KEJ.S01__SV_Delly_Filt01.xlsx") %>%
    mutate(Sample=gsub(".*__","",SID)) %>%
    select(Sample,everything()) %>%
    filter(Sample %in% samps) %>%
    arrange(Sample,factor(query.chr,levels=c(1:22,"X","Y")),query.start) %>%
    mutate(weight=SplitReadCount+PairEndCount)

openxlsx::write.xlsx(xx,"Proj_KEJ.S01__SV_Delly_Filt01__OGMSamples.xlsx")

x2=xx %>%
    filter(!is.na(query.startfeature) & !is.na(query.endfeature)) %>%
    group_split(Sample)


for(xi in x2) {

    bedA=xi %>% select(chr=query.chr,mid=query.start) %>% mutate(chr=paste0("chr",chr))
    bedB=xi %>% select(chr=query.chr2,mid=query.end) %>% mutate(chr=paste0("chr",chr))

    gA=xi %>% select(chr=query.chr,start=query.start,genes=query.startfeature) %>% mutate(end=start+1) %>% select(chr,start,end,genes) %>% separate_rows(genes,sep=",") %>% mutate(genes=gsub("\\(.*","",genes))
    gB=xi %>% select(chr=query.chr2,start=query.end,genes=query.endfeature) %>% mutate(end=start+1) %>% select(chr,start,end,genes) %>% separate_rows(genes,sep=",") %>% mutate(genes=gsub("\\(.*","",genes))

    gannote=bind_rows(gA,gB) %>% mutate(chr=paste0("chr",chr)) %>% mutate(genes=substr(genes,1,10)) %>% distinct(genes,.keep_all=T)

    # gB=bedB %>% mutate(start=mid-1,end=mid) %>% select(-mid)
    # gA=bedA %>% mutate(start=mid-1,end=mid) %>% select(-mid)
    # gannote=bind_rows(gA,gB)


    pdf(file=cc("circos_OGM",xi$Sample[1],".pdf"),width=14,height=14)

    circos.par("track.height" = 0.1, cell.padding = c(0, 0, 0, 0))
    circos.initializeWithIdeogram(plotType=c("labels", "axis"))
    circos.genomicLabels(gannote,labels.column=4,side="outside",labels_height=cm_h(1.85))

    circos.genomicIdeogram()

    clrs=rep(cols25(),2)[1:nrow(xi)]
    colors=add_transparency(clrs,.5)
    circos.genomicLink(bedA,bedB,lwd=sqrt(xi$weight),col = colors,  border = NA)

    title(gsub(".*__","",xi$SID[1]))

    dev.off()


}