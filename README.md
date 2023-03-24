
# IntegrationFeatureHeatmap

Are the number of integration sites found within or near interesting genomic areas significant? 

`IntegrationFeatureHeatmap` looks at the number of integration sites within biological features, such as DNase sensitive regions, epigenetic markers, or transcription units, and compares it to random model or an experimental control.

A heatmap object is produced as an output.


<img src="docs/testset_heatmap.png" alt="Example of heatmap" width=1000>


`IntegrationFeatureHeatmap` provides all objects generated during processing, allowing for heatmaps and ROC data to be easily accessed, modified, and used in downstream applications.


---


# Install

```r
devtools::install_github('agmcfarland/IntegrationFeatureHeatmap')
```


# Example


## Load libraries and paths

Make sure you have downloaded all data from ```https://github.com/agmcfarland/IntegrationFeatureHeatmap/data``` to a local directory

```R
# clear workspace
rm(list=ls())
options(scipen = 999)

# load libraries
library(IntegrationFeatureHeatmap)
library(dplyr)

# download the provided data from agmcfarland/IntegrationFeatureHeatmap/data to a local directory
provided_data <- '/data/IntegrationFeatureHeatmap/data'

```

## Format integration site table

Read in a dataframe of integration sites in the format outputted by AAVengeR.

```R
# read in testset.csv, which contains an example AAVengeR integration sites dataframe
aavenger_sites_raw <- read.csv(file.path(provided_data,'testset.csv'))

print(head(aavenger_sites_raw))

# format dataframe object to be useable by IntegrationFeatureHeatmap
aavenger_sites <- IntegrationFeatureHeatmap::format_aavenger_sites(
  aavenger_sites_df = aavenger_sites_raw
)

print(head(aavenger_sites))
```

## Get chromosome lengths

Read in the genomic fasta file that will be used for random sampling.

Normally the genomic fasta would be read in using ShortRead::readFasta(). However, this uses a lot of space. A pre-made chromosome_lengths file is used here for convenience. The hashed out examples show how the genomic fasta would be read in and converted to a chromosome_lengths dataframe.

```R
# genome_fasta <- ShortRead::readFasta(file.path('/home/ubuntu/temp_data/data','hg38.fa.gz')) # example
# chromosome_lengths <- IntegrationFeatureHeatmap::fasta_to_chromosome_lengths(genome_fasta) # example
chromosome_lengths <- read.csv(file.path(provided_data,'testset_chromosome_lengths.csv'))

print(head(chromosome_lengths))
```

## Make random-matched dataframes

Each unique `heatmap_group` in `aavenger_sites` is its own dataframe. Each unique `heatmap_group` dataframe will have a random match dataframe with `match_row_number_modifier` times the rows, each with a randomly sampled position from the provided genomic fasta in `chromosome_lengths`.

```R
# generate random-matched dataframes
random_match_df <- IntegrationFeatureHeatmap::aavenger_sites_random_match(
  aavenger_sites = aavenger_sites,
  chromosome_lengths = chromosome_lengths,
  random_seed_value = 10,
  match_row_number_modifier = 3
  )
  
print(head(random_match_df))
```

## Combine original integration sites and random match integration sites

Make a long dataframe that is the original aavenger_sites on top of the random_match_df sites.

```R
# combine random match and experimental dataframes
combined_df <- rbind(aavenger_sites, random_match_df)
```

## Check that each integration dataframe has the correct number of random matches

Number of random matches should equal the size of the integration dataframe * `match_row_number_modifier`.

```R
# count the number of insertion sites and match sites
print(combined_df%>%group_by(heatmap_group, type)%>%summarize(count = n()))
```

## Count overlaps for integration sites and genomic features over multiple genomic windows

Each integration site is checked if it overlaps a genomic feature, with the genomic feature being expanded by different genomic windows. 

```R
# get the provided RData and rds feature files into a list
feature_files_to_process <- list.files(provided_data, pattern = "\\.(rds|RData)$", full.names = TRUE)

print(feature_files_to_process)

# test each integration site for overlap in each feature at each given overlap 
combined_overlap_test_results_genomic_ranges <- IntegrationFeatureHeatmap::test_for_overlaps(
  matched_aavenger_sites_df = combined_df,
  list_of_feature_files = feature_files_to_process,
  overlap_ranges_to_test = c(1000, 10000, 1000000)
)

print(head(combined_overlap_test_results_genomic_ranges))
```

## Use hotROCs to calculate the ROC area for each integration site group

`IntegrationFeatureHeatmap` calls on `hotROCs` to calculate the ROC area.

```R
hot_roc_result <- IntegrationFeatureHeatmap::hotroc_compare_insertion_to_match(
  matched_overlap_df = combined_overlap_test_results_genomic_ranges
  )
```

## Inspect the hotROCs output

If the ROC is 1, then counts in the experimental integration site dataframe are greater than the random match. If the ROC is 0, then counts are lower than the random match. If the ROC is 0.5, then counts are equally likely for both experimental integration site dataframe and its random match. [See here for code](https://github.com/BushmanLab/hotROCs) and [here for more details](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5363318/)

```R
head(IntegrationFeatureHeatmap::format_hot_roc_result(hot_roc_result))
```

## Make a heatmap of the ROC data

Convert the hotROCs output into a heatmap. P-values and ROC gradients are displayed. 

```R
p1 <- IntegrationFeatureHeatmap::roc_to_heatmap(
  hot_roc_result = hot_roc_result
)
print(p1)
```


## Next steps

The heatmap object can be further edited to fit whatever data needs are requird. The ROC areas and p-values are easily accessible using ```IntegrationFeatureHeatmap::format_hot_roc_result()```.


# Data formats

`IntegrationFeatureHeatmap` takes three inputs:

1. Fasta file of the genome to use for random sampling.

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
