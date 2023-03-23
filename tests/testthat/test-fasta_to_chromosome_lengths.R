testthat::test_that('ShortRead works', {

  genome_fasta <- ShortRead::ShortRead((DNAStringSet(c('ACTGACTGACTGACTG','GGGGGGGGGGGGGGGGGGGG','CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'))))

  testthat::expect_equal(ShortRead::width(genome_fasta)[1], 16)

  testthat::expect_equal(ShortRead::width(genome_fasta)[2], 20)

  testthat::expect_equal(ShortRead::width(genome_fasta)[3], 44)
})

testthat::test_that('fasta_to_chromosome_lengths works', {

  genome_fasta <- ShortRead::ShortRead(DNAStringSet(c('ACTGACTGACTGACTG','GGGGGGGGGGGGGGGGGGGG','CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC')))

  genome_fasta@id <- BStringSet(c('chr1','chr2','chr3'))

  chromosome_lengths <- IntegrationFeatureHeatmap::fasta_to_chromosome_lengths(genome_fasta = genome_fasta)

  testthat::expect_equal(chromosome_lengths$seqname, c('chr3','chr2','chr1'))

  testthat::expect_equal(chromosome_lengths$chr_length, c(44,20,16))

})

