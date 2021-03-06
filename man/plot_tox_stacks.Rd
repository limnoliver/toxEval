% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_tox_stacks.R
\name{plot_tox_stacks}
\alias{plot_tox_stacks}
\title{Plot stacked bar charts}
\usage{
plot_tox_stacks(chemicalSummary, chem_site, category = "Biological",
  mean_logic = FALSE, sum_logic = TRUE, manual_remove = NULL,
  include_legend = TRUE, font_size = NA, title = NA)
}
\arguments{
\item{chemicalSummary}{Data frame from \code{\link{get_chemical_summary}}.}

\item{chem_site}{Data frame with at least columns SiteID, site_grouping, and Short Name.}

\item{category}{Character. Either "Biological", "Chemical Class", or "Chemical".}

\item{mean_logic}{Logical.  \code{TRUE} displays the mean sample from each site,
\code{FALSE} displays the maximum sample from each site.}

\item{sum_logic}{Logical. \code{TRUE} sums the EARs in a specified grouping,
\code{FALSE} does not. \code{FALSE} may be better for traditional benchmarks as
opposed to ToxCast benchmarks.}

\item{manual_remove}{Vector of categories to remove.}

\item{include_legend}{Logical. Used to include legend or not.}

\item{font_size}{Numeric value to adjust the axis font size.}

\item{title}{Character title for plot.}
}
\description{
The \code{plot_tox_stacks} function creates a set of boxplots representing EAR 
values computed with the \code{\link{get_chemical_summary}} function, and 
dependent on the choice of several input options. See "Summarizing the data" 
in the Introduction vignette: \url{../doc/Introduction.html#summarize_data}
for a description on how the EAR values are computed, aggregated, and summarized. 
Choosing "Chemical Class" in the category argument will generate separate stacked 
bars for each unique class. "Chemical" will generate stacked bars for each individual 
chemical, and "Biological" will generate stacked bars for each group in the selected 
ToxCast annotation. The legend can optionally be turned on or off using the
include_legend argument. It may be impractical for instance to show the 
legend for "Chemical" if there are hundreds of chemicals.
}
\details{
The graph displays a slightly different result for a single site. Providing 
data with only one site displays each individual sample as a stacked bar 
rather than the mean or maximum for a site.
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
                                       
plot_tox_stacks(chemicalSummary, tox_list$chem_site, "Biological")   
plot_tox_stacks(chemicalSummary, tox_list$chem_site, "Chemical Class")
plot_tox_stacks(chemicalSummary, tox_list$chem_site, "Chemical", include_legend = FALSE) 

# To turn off clipping:
class_plot <- plot_tox_stacks(chemicalSummary, "Chemical Class")
gb <- ggplot2::ggplot_build(class_plot)
gt <- ggplot2::ggplot_gtable(gb)

gt$layout$clip[gt$layout$name=="panel-1-1"] <- "off"

grid::grid.draw(gt) 
}
}
