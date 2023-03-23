
# IntegrationFeatureHeatmap

Are the number of integration sites found within or near interesting genomic areas significant? 

`IntegrationFeatureHeatmap` looks at the number of integration sites within biological features, such as DNase sensitive regions, epigenetic markers, or transcription units, and compares it to random model or an experimental control.

A heatmap object is produced as an output.




`IntegrationFeatureHeatmap` provides all objects generated during processing, allowing for heatmaps and ROC data to be easily accessed, modified, and used in downstream applications.


# Install

```r
devtools::install_github('https://github.com/agmcfarland/IntegrationFeatureHeatmap')
```


# Example

```r
rm(list=ls())
options(scipen = 999)

devtools::install_github('agmcfarland/IntegrationFeatureHeatmap')
library(IntegrationFeatureHeatmap)
library(dplyr)
library(stringr)

# download the provided data from agmcfarland/IntegrationFeatureHeatmap/data to a local directory
provided_data <- '/data/IntegrationFeatureHeatmap/data'

aavenger_sites_raw <- read.csv(file.path(provided_data,'testset.csv'))

# test sites -- not using `format_aavenger_sites()` since this is an older AAVengeR output missing a few columns.
aavenger_sites <- format_aavenger_sites(
  aavenger_sites_df = aavenger_sites_raw
)
  
# fasta sequence to sample from. Going to pretend we ran the hashed code below and instead read in a pre-prepared file.
# genome_fasta <- ShortRead::readFasta(file.path('/home/ubuntu/temp_data/data','hg38.fa.gz'))
# chromosome_lengths <- IntegrationFeatureHeatmap::fasta_to_chromosome_lengths(genome_fasta)
chromosome_lengths <- read.csv(file.path('/data/IntegrationFeatureHeatmap/data/testset_chromosome_lengths.csv'))

# generate random-matched dataframes
random_match_df <- IntegrationFeatureHeatmap::aavenger_sites_random_match(
  aavenger_sites = aavenger_sites,
  chromosome_lengths = chromosome_lengths,
  random_seed_value = 10,
  match_row_number_modifier = 3
  )

# combine random match and experimental dataframes
combined_df <- rbind(aavenger_sites, random_match_df)

# count the number of insertion sites and match sites. There should be 3 times more match sites than integration sites
print(combined_df%>%group_by(heatmap_group, type)%>%summarize(count = n ()))

# get the provided RData and rds feature files into a list
feature_files_to_process <- list.files('/data/IntegrationFeatureHeatmap/data', pattern = "\\.(rds|RData)$", full.names = TRUE)

# test each integration site for overlap in each feature at each given overlap 
combined_overlap_test_results_genomic_ranges <- IntegrationFeatureHeatmap::test_for_overlaps(
  matched_aavenger_sites_df = combined_df,
  list_of_feature_files = feature_files_to_process,
  overlap_ranges_to_test = c(1000, 10000, 1000000)
)

# use hotROCs to calculate the ROC for each integration site group
hot_roc_result <- IntegrationFeatureHeatmap::hotroc_compare_insertion_to_match(
  matched_overlap_df = combined_overlap_test_results_genomic_ranges
  )

# make a heatmap of the ROC data
p1 <- roc_to_heatmap(
  hot_roc_result = hot_roc_result
)

print(p1)
```



# Data formats

`IntegrationFeatureHeatmap` takes three inputs:

1. Fasta file of the genome being tested.

2. A list of genomic features of file type `.RData` or `.rds`.

3. An `data.frame` of integration sites.

Details are provided below. 

## Fasta file

Fasta file can have single or multiple sequences. Each defline has a unique word, like chr1. Allowed bases are A, C, T, G, and N.

```
>chr1
ACTGTAGCTAGATCGATCGATCAGCTGACGACTGACGCGGAGACTACTAGCATCTACGACGACGTACTACTACGATCATCAGCTACGACG
>chr2
TTGCTGCTCGCTTTCGCTATATCATAAATCGATCGACTACGACTAGCTACTACGACTATATCACTAGCTAGCTAGTGTAGCTAGCTACAC
```

## Features

`IntegrationFeatureHeatmap` takes as input either an RData or RDS file containing a `GenomicRanges` object formatted like below:

```
GRanges object with 5 ranges and 0 metadata columns:
                         seqnames            ranges strand
                            <Rle>         <IRanges>  <Rle>
       [1]                   chr1 89128920-89129070      *
       [2]                   chr1   1441680-1441830      *
       [3]                   chr1 13500340-13500490      *
       [4]                   chr1 14811020-14811170      *
       [5]                   chr1 30801860-30802010      *
```


**Important**

If using an RData file, the `GenomicRanges` object **must** be named `epigenData`

## Integration sites

`IntegrationFeatureHeatmap` assumes you are working with an AAVengeR `data.frame` object. This is what one looks like. However, the only required columns are `trial`, `subject`, `sample`, and `posid`.

```
    trial  subject  sample refGenome            posid UMIs sonicLengths nRepsObs flags vectorFastaFile rep1.UMIs rep1.sonicLengths rep1.reads rep1.repLeaderSeq maxLeaderSeqDist
1 testset subject1 sample1      hg38 chr16-67665165.1   10           10       10    NA    random.fasta        10                10         10          ACTGACTG               10
2 testset subject1 sample1      hg38 chr3-193855322.1   10           10       10    NA    random.fasta        10                10         10          ACTGACTG               10
3 testset subject1 sample1      hg38  chr2-48952285.1   10           10       10    NA    random.fasta        10                10         10          ACTGACTG               10
4 testset subject1 sample1      hg38 chr16-31625838.1   10           10       10    NA    random.fasta        10                10         10          ACTGACTG               10
5 testset subject1 sample1      hg38 chr16-20894346.1   10           10       10    NA    random.fasta        10                10         10          ACTGACTG               10
6 testset subject1 sample1      hg38  chrX-27657690.1   10           10       10    NA    random.fasta        10                10         10          ACTGACTG               10
```

# Tips






# Citation