require(tidyverse)

tFiles=scan("tumorTbl0","")

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

    pon0=read_tsv(gsub(".uuid.pass.bnd.tbl0",".uuid.pon.tbl0",tf)) %>%
        select(ANNOID,AF,AC,NS,AN)

    pon1=read_tsv(gsub(".uuid.pass.bnd.tbl0",".uuid.pon.query.tsv.gz",tf)) %>%
        select(ANNOID,ID=query.id)

    pon0=left_join(pon1,pon0)

    tbl0=tbl0 %>% left_join(pon0) %>% filter(is.na(NS) | NS<3)

    tbl0=read_tsv(gsub(".uuid.pass.bnd.tbl0",".uuid.gene.query.tsv.gz",tf)) %>%
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

tbl2=tbl1 %>% filter(PairEndCount>3 & SplitReadCount>3) %>%
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
    "Proj_KEJ.S01__SV_Delly_Filt01.xlsx"
    )

tblG=tbl1 %>% filter(grepl("SCML2",query.startfeature)|grepl("SCML2",query.endfeature)) %>% select(SID,everything())

write_csv(tblG,"sv_Delly_DCML2.csv")

openxlsx::write.xlsx(
    list(SV.SCML2=tblG),
    "Proj_KEJ.S01__SV_Delly_SCML2.xlsx"
    )

