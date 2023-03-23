
# IntegrationFeatureHeatmap

Are the number of integration sites found within or near interesting genomic areas significant? 

`IntegrationFeatureHeatmap` looks at the number of integration sites within biological features, such as DNase sensitive regions, epigenetic markers, or transcription units, and compares it to random model or an experimental control.

The output produced is a 


# Install

```
devtools::install_github('https://github.com/agmcfarland/IntegrationFeatureHeatmap')
```


# Example



# Data formats

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
GRanges object with 212515 ranges and 0 metadata columns:
                         seqnames            ranges strand
                            <Rle>         <IRanges>  <Rle>
       [1]                   chr1 89128920-89129070      *
       [2]                   chr1   1441680-1441830      *
       [3]                   chr1 13500340-13500490      *
       [4]                   chr1 14811020-14811170      *
       [5]                   chr1 30801860-30802010      *
       ...                    ...               ...    ...
  [212511] chr22_KI270736v1_ran..     180220-180370      *
  [212512] chr22_KI270736v1_ran..     180440-180590      *
  [212513] chr22_KI270736v1_ran..     181100-181250      *
  [212514] chr22_KI270736v1_ran..     181580-181730      *
  [212515] chr22_KI270737v1_ran..       70260-70410      *

```

**Important**

If using an RData file, the `GenomicRanges` object **must** be named epigenData

## Integration sites


Here seqnames 


# Tips






# Citation