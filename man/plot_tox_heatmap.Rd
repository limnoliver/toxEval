% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_heat_chemical.R
\name{plot_tox_heatmap}
\alias{plot_tox_heatmap}
\title{plot_tox_heatmap}
\usage{
plot_tox_heatmap(chemicalSummary, chem_site, category = "Biological",
  breaks = c(1e-05, 1e-04, 0.001, 0.01, 0.1, 1, 5), manual_remove = NULL,
  mean_logic = FALSE, sum_logic = TRUE, plot_ND = TRUE, font_size = NA,
  title = NA)
}
\arguments{
\item{chemicalSummary}{Data frame from \code{\link{get_chemical_summary}}.}

\item{chem_site}{Data frame with columns SiteID, site_grouping, and Short Name.}

\item{category}{Either "Biological", "Chemical Class", or "Chemical".}

\item{breaks}{Numerical vector to define data bins and legend breaks.}

\item{manual_remove}{Vector of categories to remove.}

\item{mean_logic}{Logical.  \code{TRUE} displays the mean sample from each site,
\code{FALSE} displays the maximum sample from each site.}

\item{sum_logic}{Logical. \code{TRUE} sums the EARs in a specified grouping,
\code{FALSE} does not. \code{FALSE} may be better for traditional benchmarks as
opposed to ToxCast benchmarks.}

\item{plot_ND}{Logical. Whether or not to plot "Biological" groupings,
"Chemical Class" groupings, or "Chemical" that do not have any detections.}

\item{font_size}{Numeric value to adjust the axis font size.}

\item{title}{Character title for plot.}
}
\description{
The \code{plot_tox_heatmap} function creates a heat (tile) map with sites on the x-axis, 
a specified grouping on the y-axis (defined by the category argument), and color shading 
defining the mean or maximum EAR. See "Summarizing the data" in the Introduction vignette:  
\url{../doc/Introduction.html#summarize_data} for a description on how the 
EAR values are computed, aggregated, and summarized. The y-axis grouping can be "Biological",
"Chemical Class", or "Chemical". When specifying the "Chemical" option, a secondary y-axis 
is automatically included to group chemicals into chemical class. The function computes 
default breaks for the color scale to match the spread of the data, but breaks can also 
be customized with the breaks argument.
This is a function where it may be ideal to create a custom order to the sites 
(for example, west-to-east). See the above section "Custom configuration"
\url{../doc/Introduction.html#custom_config} for instructions on how to convert 
the character vector sites to a factor with ordered levels.
}
\examples{
path_to_tox <-  system.file("extdata", package="toxEval")
file_name <- "OWC_data_fromSup.xlsx"
full_path <- file.path(path_to_tox, file_name)
\dontrun{
tox_list <- create_toxEval(full_path)

ACClong <- get_ACC(tox_list$chem_info$CAS)
ACClong <- remove_flags(ACClong)

cleaned_ep <- clean_endPoint_info(endPointInfo)
filtered_ep <- filter_groups(cleaned_ep)

chemicalSummary <- get_chemical_summary(tox_list, ACClong, filtered_ep)
                                        
#Order the site_groupings:
tox_list$chem_site$site_grouping <- factor(tox_list$chem_site$site_grouping,
              levels=c("Lake Superior",
              "Lake Michigan",
              "Lake Huron",
              "Lake Erie",
              "Lake Ontario"))

#Order sites:
sitesOrdered <- c("StLouis","Nemadji","WhiteWI","Bad","Montreal",
"PresqueIsle","Ontonagon","Sturgeon","Tahquamenon","Burns",
"IndianaHC","StJoseph","PawPaw","Kalamazoo","GrandMI",
"Milwaukee","Muskegon","WhiteMI","PereMarquette","Manitowoc",
"Manistee","Fox","Oconto","Peshtigo","Menominee",
"Indian","Cheboygan","Ford","Escanaba","Manistique",
"ThunderBay","AuSable","Rifle","Saginaw","BlackMI",
"Clinton","Rouge","HuronMI","Raisin","Maumee",
"Portage","Sandusky","HuronOH","Vermilion","BlackOH",
"Rocky","Cuyahoga","GrandOH","Cattaraugus","Tonawanda",
"Genesee","Oswego","BlackNY","Oswegatchie","Grass",
"Raquette","StRegis")

tox_list$chem_site$`Short Name` <- factor(tox_list$chem_site$`Short Name`,
              levels = sitesOrdered)
              
plot_tox_heatmap(chemicalSummary, 
                 tox_list$chem_site, 
                 category = "Biological",
                 manual_remove = "Undefined")
plot_tox_heatmap(chemicalSummary, tox_list$chem_site, category = "Chemical Class")
plot_tox_heatmap(chemicalSummary, tox_list$chem_site, category = "Chemical")
}
}
