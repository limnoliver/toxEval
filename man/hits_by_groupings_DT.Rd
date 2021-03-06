% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hits_by_groupings.R
\name{hits_by_groupings_DT}
\alias{hits_by_groupings_DT}
\alias{hits_by_groupings}
\title{Biological hits per category}
\usage{
hits_by_groupings_DT(chemicalSummary, category = "Biological",
  mean_logic = FALSE, sum_logic = TRUE, hit_threshold = 0.1)

hits_by_groupings(chemicalSummary, category, mean_logic = FALSE,
  sum_logic = TRUE, hit_threshold = 0.1)
}
\arguments{
\item{chemicalSummary}{Data frame from \code{\link{get_chemical_summary}}.}

\item{category}{Character. Either "Biological", "Chemical Class", or "Chemical".}

\item{mean_logic}{Logical.  \code{TRUE} displays the mean sample from each site,
\code{FALSE} displays the maximum sample from each site.}

\item{sum_logic}{Logical. \code{TRUE} sums the EARs in a specified grouping,
\code{FALSE} does not. \code{FALSE} may be better for traditional benchmarks as
opposed to ToxCast benchmarks.}

\item{hit_threshold}{Numeric threshold defining a "hit".}
}
\description{
The \code{hits_by_groupings_DT} (DT option) and 
\code{hits_by_groupings} (data frame option) functions create tables 
with one row per category("Biological", "Chemical", or "Chemical Class"). 
The columns indicate the "Biological" groupings. The values in the table 
signify how many sites have samples with EARs that exceeded the hit_threshold 
for that particular "Biological"/category combination. If the user chooses 
"Biological" as the category, it is a simple 2-column table of "Biological" 
groupings and number of sites (nSites).
}
\details{
The tables result in slightly different results for a single site, displaying 
the number of samples with hits rather than the number of sites.
}
\examples{
# This is the example workflow:
path_to_tox <-  system.file("extdata", package="toxEval")
file_name <- "OWC_data_fromSup.xlsx"

full_path <- file.path(path_to_tox, file_name)

tox_list <- create_toxEval(full_path)
\dontrun{
ACClong <- get_ACC(tox_list$chem_info$CAS)
ACClong <- remove_flags(ACClong)

cleaned_ep <- clean_endPoint_info(endPointInfo)
filtered_ep <- filter_groups(cleaned_ep)
chemicalSummary <- get_chemical_summary(tox_list, ACClong, filtered_ep)

site_df <- hits_by_groupings(chemicalSummary, category = "Biological")
hits_by_groupings_DT(chemicalSummary, category = "Biological")
hits_by_groupings_DT(chemicalSummary, category = "Chemical Class")
hits_by_groupings_DT(chemicalSummary, category = "Chemical")
}
}
