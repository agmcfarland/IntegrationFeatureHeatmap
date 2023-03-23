testthat::test_that('Format AAVengeR works', {

  aavenger_table <- data.frame(
    'trial' = rep('example_trial', 10),
    'subject' = rep(c('subject1','subject2'), 5),
    'sample' = rep(c('sample1','sample2'), 5),
    'refGenome' = 'hg38',
    'posid' = rep(c('chr1+5.1','chr2-5.1','chr3+5.1','chr1+10.1','chr2-10.1'), 2),
    'UMIs' = rep(5,10),
    'sonicLengths' = rep(5,10),
    'reads' = rep(10,10),
    'repLeaderSeq' = rep('ACTGACTG', 10),
    'nRepsObs' = rep(10,10),
    'flags' = '',
    'vectorFastaFile' = 'random.fasta',
    'rep1-UMIs' = rep(5,10),
    'rep1-sonicLengths'= rep(5,10),
    'rep1-reads' = rep(10,10),
    'rep1-repLeaderSeq' = rep('ACTGACTG', 10),
    'maxLeaderSeqDist' = rep(0,10)
  )

  formatted_aavenger_table <- format_aavenger_sites(
    aavenger_sites_df = aavenger_table
    )

  unique_heatmap_group <- unique(formatted_aavenger_table$heatmap_group)

  testthat::expect_equal(formatted_aavenger_table$start, formatted_aavenger_table$end)

  testthat::expect_equal(formatted_aavenger_table$start, formatted_aavenger_table$mid)

  testthat::expect_equal(unique(formatted_aavenger_table$type), 'insertion')

  testthat::expect_equal(unique(formatted_aavenger_table$strand), '*')

  testthat::expect_equal(unique(formatted_aavenger_table$seqname), c('chr1','chr2','chr3'))

  testthat::expect_equal((unique(formatted_aavenger_table$start)), c(5, 10))

})
