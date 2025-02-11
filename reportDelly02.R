require(tidyverse)

tFiles=scan("tumorAllTbl0","")

#tf=tFiles[1]

read_delly_plus_annote<-function(tf) {
    tbl0=read_tsv(tf) %>%
        bind_rows %>%
        mutate(SR=ifelse(SR==".",0,SR)%>%as.numeric) %>%
        mutate(SRMAPQ=ifelse(SRMAPQ==".",0,SRMAPQ)%>%as.numeric) %>%
        rename(
            PairEndCount=PE,SplitReadCount=SR,
            PEDepthREF=DR,PEDepthALT=DV,
            SplitCountREF=RR,SplitCountALT=RV
            )

    pon0=read_tsv(gsub(".uuid.pass.all.tbl0",".uuid.pon.tbl0",tf)) %>%
        select(ANNOID,AF,AC,NS,AN)

    pon1=read_tsv(gsub(".uuid.pass.all.tbl0",".uuid.pon.query.tsv.gz",tf)) %>%
        select(ANNOID,ID=query.id)

    pon0=left_join(pon1,pon0)

    tbl0=tbl0 %>% left_join(pon0) %>% filter(is.na(NS) | NS<3)

    tbl0=read_tsv(gsub(".uuid.pass.all.tbl0",".uuid.gene.query.tsv.gz",tf)) %>%
        select(ID=query.id,everything()) %>%
        select(-ANNOID) %>%
        right_join(tbl0) %>%
        select(-ID,ID)
    tbl0
}


tbl1=map(tFiles,read_delly_plus_annote) %>%
    bind_rows %>%
    mutate(SID=gsub(":[A-Z0-9]+","",ID)) %>%
    arrange(desc(query.qual))

tCellGenes=scan("rsrc/tCellReceptorGenes","")
geneFeatureTbl=tbl1 %>%
    select(SID,ID,matches("feature")) %>%
    gather(End,Feature,matches("feature")) %>%
    filter(!is.na(Feature)) %>%
    separate_rows(Feature,sep=",") %>%
    mutate(Gene=gsub("\\(.*","",Feature))

tCellEvents=geneFeatureTbl %>% filter(Gene %in% tCellGenes) %>% pull(ID)

tbl2=tbl1 %>%
    filter(ID %in% tCellEvents) %>%
    select(-AF,-AC,-NS,-AN)


geneTbl=tbl2 %>%
    arrange(desc(query.qual)) %>%
    select(SID,query.startfeature,query.endfeature) %>%
    filter(!is.na(query.startfeature)) %>%
    filter(!is.na(query.endfeature)) %>%
    distinct %>%
    count(query.startfeature,query.endfeature) %>%
    arrange(desc(n)) %>%
    filter(n>1)

openxlsx::write.xlsx(
    list(SVTbl=tbl2,GeneTbl=geneTbl),
    "Proj_KEJ.S01__SV_Delly_TCellGeneEvents.xlsx"
    )

