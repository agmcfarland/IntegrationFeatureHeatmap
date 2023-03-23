#' Test for Overlaps
#'
#' @description Test a list of Rdata files for genomic overlaps with integration site positions and count the number of overlaps.
#'
#' @param matched_aavenger_sites_df A `data.frame` object containing specifically formatted match and insertion sites for each heatmap_group. See `format_aavenger_sites()`.
#' @param list_of_Rdata_files A `list` object of RData files containing a `GRanges` object called `epigenData` with the following columns:
#' \describe{
#' \item{seqname}{name of the chromosome. Must match those in `matched_aavenger_sites_df`}.
#' \item{ranges}{An `IRanges` object with a genomic range.}
#' \item{Rle}{The strand the range is located in. Should be set to `*`.}
#' \item{mid}{The mid point between the two values in the `ranges` column.}}
#' @param overlap_ranges_to_test A `numeric` `vector` of the different genomic windows to use in the overlap test. Values must be integers.
#'
#' @return A dataframe containing the original `matched_aavenger_sites_df` and a column of overlap counts per each file from `list_of_Rdata_files`.
#'
#' @examples
#' test_for_overlaps(matched_aavenger_sites_df, list_of_Rdata_files = list.files(path_to_RData_files), overlap_ranges_to_test = c(1000,10000,1000000))
#'
#' @import GenomicRanges tibble dplyr
#'
#' @export
test_for_overlaps <- function(
    matched_aavenger_sites_df,
    list_of_Rdata_files,
    overlap_ranges_to_test
){

  # Make a string version of overlap ranges to test
  options(scipen=999) # ensures that 1000000 doesn't turn into 1e6, etc
  overlap_ranges_to_test_string <- as.character(overlap_ranges_to_test)

  ## Make empty dataframe to store results of test
  # names of columns in vector format
  store_overlap_results_colnames <- outer(data_to_test, overlap_ranges_to_test_string, paste, sep = '.')
  store_overlap_results_colnames <- as.vector(t(store_overlap_results_colnames))

  # Create an empty matrix of the following dimensions
  # number of rows = number of all sites to test
  # number of columns = number of different overlaps to test multipled by the number of different datasets to test
  store_overlap_results <- matrix(
    0, #fill with zeros
    nrow = nrow(matched_aavenger_sites_df),
    ncol = length(store_overlap_results_colnames),
    dimnames = list(NULL,store_overlap_results_colnames)
  )

  store_overlap_results <- tibble::as_tibble(store_overlap_results) # why is this as_tibble instead of a dataframe?

  ## Count overlaps for each overlap range in each dataset
  # Make a genomic ranges version of the submit dataframe
  matched_aavenger_sites_df_genomic_ranges <- GenomicRanges::makeGRangesFromDataFrame(matched_aavenger_sites_df, keep.extra.columns = TRUE)

  # Begin for loop to loop over biological RData objects
  for (biological_data in data_to_test){
    print(biological_data)

    # Load the RData object with biological ranges
    load(file.path(data_dir, biological_data))

    # Enter loop. For each single overlap range value count the genomic overlaps
    for (single_overlap_value in overlap_ranges_to_test){

      # name of the biological dataset and the overlap value to be used. will match a column name in the pre-created `store_overlap_results`
      data_name_and_overlap_value <- paste(biological_data, single_overlap_value, sep = '.')

      # count the overlaps
      overlap_count_results <- GenomicRanges::countOverlaps(
        query = matched_aavenger_sites_df_genomic_ranges, # The GRanges object containing ALL sites to be tested for overlaps
        subject = epigenData, # epigenData is name of the GRanges object that is loaded in the biological .RData file
        maxgap = single_overlap_value/2, # the overlap value is halved and subtracted from the single value range object to create a range
        ignore.strand = TRUE
      )

      # store the overlaps in the corresponding column
      store_overlap_results[data_name_and_overlap_value] <- overlap_count_results
    }
  }

  ## Create a genomic ranges object
  # Start with the dataframe of insertion sites `matched_aavenger_sites_df` and the overlap test results `store_overlap_results`
  combined_overlap_test_results_genomic_ranges <- cbind(
    matched_aavenger_sites_df,
    store_overlap_results
  )
}
