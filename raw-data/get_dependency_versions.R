dependencies <- c('GenomicRanges', 'ShortRead', 'ggplot2', 'hotROCs', 'stringr', 'tibble', 'tidyr', 'Biostrings')

dependency_df <- lapply(dependencies, function(package){
  package_information <- c(package, as.character(packageVersion(package)) )
  return(package_information)
})

dependency_df <- as.data.frame(do.call(rbind, dependency_df))

colnames(dependency_df) <- c('package', 'version')

write.csv(dependency_df, file.path('/data/IntegrationFeatureHeatmap/docs', 'dependencies.csv'), row.names = FALSE)