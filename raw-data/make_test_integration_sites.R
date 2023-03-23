
library(dplyr)

load('/home/ubuntu/temp_data/data/H3K79me2.RData')

set.seed(30)

number_of_sites <- 1000

test_positive <- rbind(data.frame(epigenData)%>%
                         slice_sample(n = number_of_sites, replace = FALSE)%>%
                         rowwise()%>%
                         mutate(
                           trial = 'testset',
                           subject = 'subject1',
                           sample = 'sample1',
                           refGenome = 'hg38',
                           posid = ifelse(is.integer(start/2) == TRUE, paste0(seqnames,'+',start,'.1'), paste0(seqnames,'-',start,'.1')),
                           UMIs = 10,
                           sonicLengths = 10,
                           nRepsObs = 10,
                           flags = '',
                           vectorFastaFile = 'random.fasta',
                           `rep1-UMIs` = 10,
                           `rep1-sonicLengths` = 10,
                           `rep1-reads` = 10,
                           `rep1-repLeaderSeq` = 'ACTGACTG',
                           maxLeaderSeqDist = 10
                         ),
                       data.frame(epigenData)%>%
                         slice_sample(n = number_of_sites, replace = FALSE)%>%
                         rowwise()%>%
                         mutate(
                           trial = 'testset',
                           subject = 'subject2',
                           sample = 'sample1',
                           refGenome = 'hg38',
                           posid = ifelse(is.integer(start/2) == TRUE, paste0(seqnames,'+',start,'.1'), paste0(seqnames,'-',start,'.1')),
                           UMIs = 10,
                           sonicLengths = 10,
                           nRepsObs = 10,
                           flags = '',
                           vectorFastaFile = 'random.fasta',
                           `rep1-UMIs` = 10,
                           `rep1-sonicLengths` = 10,
                           `rep1-reads` = 10,
                           `rep1-repLeaderSeq` = 'ACTGACTG',
                           maxLeaderSeqDist = 10
                         )
                       
)

test_positive <- test_positive%>%
  select(-c(seqnames, start, end, width, strand, mid))
# IntegrationFeatureHeatmap::format_aavenger_sites(test_positive)

write.csv(test_positive, file.path('/data/IntegrationFeatureHeatmap/data'), row.names = FALSE)