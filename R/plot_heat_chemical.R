#' plot_heat_chemicals
#' 
#' Plot heat map
#' @param graphData data frame from \code{graph_chem_data}
#' @param chem_site data frame with at least columns SiteID, site_grouping,  and Short Name
#' @export
#' @import ggplot2
#' @importFrom stats median
#' @importFrom dplyr full_join filter mutate left_join right_join
#' @examples
#' library(readxl)
#' path_to_tox <-  system.file("extdata", package="toxEval")
#' file_name <- "OWC_data_fromSup.xlsx"
#' full_path <- file.path(path_to_tox, file_name)
#' 
#' chem_data <- read_excel(full_path, sheet = "Data")
#' chem_info <- read_excel(full_path, sheet = "Chemicals") 
#' chem_site <- read_excel(full_path, sheet = "Sites")
#' ACClong <- get_ACC(chem_info$CAS)
#' ACClong <- remove_flags(ACClong)
#' 
#' cleaned_ep <- clean_endPoint_info(endPointInfo)
#' filtered_ep <- filter_groups(cleaned_ep)
#' 
#' chemicalSummary <- get_chemical_summary(ACClong,
#'                                         filtered_ep,
#'                                        chem_data, 
#'                                         chem_site, 
#'                                         chem_info)
#' 
#' graphData <- graph_chem_data(chemicalSummary)
#' plot_heat_chemicals(graphData, chem_site)
#' #Order the site_groupings:
#' chem_site$site_grouping <- factor(chem_site$site_grouping,
#'               levels=c("Lake Superior",
#'               "Lake Michigan",
#'               "Lake Huron",
#'               "Lake Erie",
#'               "Lake Ontario"))
#' plot_heat_chemicals(graphData, chem_site)
#' #Order sites:
#' sitesOrdered <- c("StLouis","Nemadji","WhiteWI","Bad","Montreal",
#' "PresqueIsle","Ontonagon","Sturgeon","Tahquamenon","Burns",
#' "IndianaHC","StJoseph","PawPaw","Kalamazoo","GrandMI",
#' "Milwaukee","Muskegon","WhiteMI","PereMarquette","Manitowoc",
#' "Manistee","Fox","Oconto","Peshtigo","Menominee",
#' "Indian","Cheboygan","Ford","Escanaba","Manistique",
#' "ThunderBay","AuSable","Rifle","Saginaw","BlackMI",
#' "Clinton","Rouge","HuronMI","Raisin","Maumee",
#' "Portage","Sandusky","HuronOH","Vermilion","BlackOH",
#' "Rocky","Cuyahoga","GrandOH","Cattaraugus","Tonawanda",
#' "Genesee","Oswego","BlackNY","Oswegatchie","Grass",
#' "Raquette","StRegis")
#' 
#' chem_site$`Short Name` <- factor(chem_site$`Short Name`,
#'               levels = sitesOrdered)
#' plot_heat_chemicals(graphData, chem_site)
plot_heat_chemicals <- function(graphData, chem_site){
  
  SiteID <- site_grouping <- `Short Name` <- chnm <- maxEAR <- ".dplyr"
  site <- EAR <- sumEAR <- meanEAR <- ".dplyr"
  
  graphData <- graphData %>%
    left_join(chem_site[, c("SiteID", "site_grouping", "Short Name")],
              by=c("site"="SiteID"))
  
  heat <- ggplot(data = graphData) +
    geom_tile(aes(x = `Short Name`, y=chnm, fill=maxEAR)) +
    theme_bw() +
    theme(axis.text.x = element_text( angle = 90,vjust=0.5,hjust = 1)) +
    ylab("") +
    xlab("") +
    labs(fill="Maximum EAR") +
    scale_fill_gradient( guide = "legend",
                         trans = 'log',
                         low = "white", high = "steelblue",
                         breaks=c(0.00001,0.0001,0.001,0.01,0.1,1,5),
                         na.value = 'transparent',labels=fancyNumbers2) +
    facet_grid(Class ~ site_grouping, scales="free", space="free") +
    theme(strip.text.y = element_text(angle=0, hjust=0), 
          strip.background = element_rect(fill="transparent", colour = NA),
          # axis.text.y = element_text(face=ifelse(levels(graphData$category) %in% c("Total"),"bold","italic")),
          panel.spacing = unit(0.05, "lines"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "transparent",colour = NA))
  
  return(heat)
  
}


#' plot_tox_heatmap
#' 
#' Plot heat map
#' @param chemicalSummary data frame from \code{get_chemical_summary}
#' @param chem_site data frame with at least columns SiteID, site_grouping,  and Short Name
#' @param category either "Biological", "Chemical Class", or "Chemical"
#' @param manual_remove vector of categories to remove
#' @param mean_logic logical \code{TRUE} is mean, \code{FALSE} is maximum
#' @param plot_ND logical whether or not to plot the non-detects
#' @export
#' @import ggplot2
#' @importFrom stats median
#' @importFrom dplyr full_join filter mutate left_join right_join
#' @examples
#' library(readxl)
#' path_to_tox <-  system.file("extdata", package="toxEval")
#' file_name <- "OWC_data_fromSup.xlsx"
#' full_path <- file.path(path_to_tox, file_name)
#' 
#' chem_data <- read_excel(full_path, sheet = "Data")
#' chem_info <- read_excel(full_path, sheet = "Chemicals") 
#' chem_site <- read_excel(full_path, sheet = "Sites")
#' ACClong <- get_ACC(chem_info$CAS)
#' ACClong <- remove_flags(ACClong)
#' 
#' cleaned_ep <- clean_endPoint_info(endPointInfo)
#' filtered_ep <- filter_groups(cleaned_ep)
#' 
#' chemicalSummary <- get_chemical_summary(ACClong,
#'                                         filtered_ep,
#'                                        chem_data, 
#'                                         chem_site, 
#'                                         chem_info)
#' #Order the site_groupings:
#' chem_site$site_grouping <- factor(chem_site$site_grouping,
#'               levels=c("Lake Superior",
#'               "Lake Michigan",
#'               "Lake Huron",
#'               "Lake Erie",
#'               "Lake Ontario"))
#' 
#' #Order sites:
#' sitesOrdered <- c("StLouis","Nemadji","WhiteWI","Bad","Montreal",
#' "PresqueIsle","Ontonagon","Sturgeon","Tahquamenon","Burns",
#' "IndianaHC","StJoseph","PawPaw","Kalamazoo","GrandMI",
#' "Milwaukee","Muskegon","WhiteMI","PereMarquette","Manitowoc",
#' "Manistee","Fox","Oconto","Peshtigo","Menominee",
#' "Indian","Cheboygan","Ford","Escanaba","Manistique",
#' "ThunderBay","AuSable","Rifle","Saginaw","BlackMI",
#' "Clinton","Rouge","HuronMI","Raisin","Maumee",
#' "Portage","Sandusky","HuronOH","Vermilion","BlackOH",
#' "Rocky","Cuyahoga","GrandOH","Cattaraugus","Tonawanda",
#' "Genesee","Oswego","BlackNY","Oswegatchie","Grass",
#' "Raquette","StRegis")
#' 
#' chem_site$`Short Name` <- factor(chem_site$`Short Name`,
#'               levels = sitesOrdered)
#'               
#' plot_tox_heatmap(chemicalSummary, 
#'                  chem_site, 
#'                  category = "Biological",
#'                  manual_remove = "Undefined")
#' plot_tox_heatmap(chemicalSummary, chem_site, category = "Chemical Class")
#' plot_tox_heatmap(chemicalSummary, chem_site, category = "Chemical")
plot_tox_heatmap <- function(chemicalSummary, 
                             chem_site, 
                             category = "Biological",
                             manual_remove = NULL,
                             mean_logic = FALSE,
                             plot_ND = TRUE){
  
  match.arg(category, c("Biological","Chemical Class","Chemical"))
  
  SiteID <- site_grouping <- `Short Name` <- chnm <- maxEAR <- ".dplyr"
  site <- EAR <- sumEAR <- meanEAR <- ".dplyr"
  
  if(!plot_ND){
    chemicalSummary <- chemicalSummary[chemicalSummary$EAR > 0,]
  }
  
  if(category == "Chemical"){
    graphData <- graph_chem_data(chemicalSummary, mean_logic=mean_logic)
    plot_back <- plot_heat_chemicals(graphData=graphData, chem_site=chem_site)
    
  } else {
    
    graphData <- graphData(chemicalSummary = chemicalSummary,
                           category = category,
                           manual_remove = manual_remove,
                           mean_logic = mean_logic)
    
    graphData <- graphData %>%
      left_join(chem_site[, c("SiteID", "site_grouping", "Short Name")],
                by=c("site"="SiteID"))
    
    
    plot_back <- ggplot(data = graphData) +
      geom_tile(aes(x = `Short Name`, y=category, fill=meanEAR)) +
      theme_bw() +
      theme(axis.text.x = element_text( angle = 90,vjust=0.5,hjust = 1)) +
      ylab("") +
      xlab("") +
      labs(fill="Maximum EAR") +
      scale_fill_gradient( guide = "legend",
                           trans = 'log',
                           low = "white", high = "steelblue",
                           breaks=c(0.00001,0.0001,0.001,0.01,0.1,1,5),
                           na.value = 'transparent',labels=fancyNumbers2) +
      facet_grid(. ~ site_grouping, scales="free", space="free") +
      theme(strip.text.y = element_text(angle=0, hjust=0), 
            strip.background = element_rect(fill="transparent", colour = NA),
            panel.spacing = unit(0.05, "lines"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.background = element_rect(fill = "transparent",colour = NA))

  }
  
  return(plot_back)
}





