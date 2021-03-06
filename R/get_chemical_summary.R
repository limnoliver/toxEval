#' Compute EAR values from measured concentrations and ACC values.
#' 
#' This function computes Exposure:Activity ratios using user-provided measured 
#' concentration data from the output of \code{\link{create_toxEval}},
#' and joins the data with the activity concentration at cutoff data provided by 
#' ToxCast.Data from ToxCast is included with this package, but alternative 
#' benchmark data can be provided to perform the same "toxEval" analysis.
#' 
#' To use the data provided by the package, a sample workflow is shown below
#' in the examples. The examples include retrieving the ToxCast (ACC) values 
#' that are used to calculate EARs, choosing endPoints that should be ignored 
#' based on data quality "flags" in the ToxCast database, and removing groups of 
#' endPoints that may not be important to the analysis at hand.
#' 
#' 
#' @param tox_list List with data frames for chem_data, chem_info, chem_site, 
#' and optionally exclusions and benchmarks. Created with \code{\link{create_toxEval}}.
#' @param ACClong Data frame with columns: CAS, chnm, endPoint, and ACC_value 
#' for specific chemical/endpoint combinations generated using the 
#' \code{\link{get_ACC}} function. EndPoints with specific data quality flags 
#' may optionally be removed using the \code{\link{remove_flags}} function.
#' @param filtered_ep Data frame with colums: endPoints, groupCol. Default is \code{"All"}, where no
#' filtering occurs.
#' @param chem.data \emph{Optional} data frame with (at least) columns: CAS, SiteID, and Value. Default is \code{NULL}. 
#' The argument will over-ride what is in tox_list.
#' @param chem.site \emph{Optional} data frame with (at least) columns: SiteID, and Short Name. Default is \code{NULL}. 
#' The argument will over-ride what is in tox_list.
#' @param chem.info \emph{Optional} data frame with (at least) columns: CAS, and class. Default is \code{NULL}. 
#' The argument will over-ride what is in tox_list.
#' @param exclusion \emph{Optional} data frame with (at least) columns: CAS and endPoint. Default is \code{NULL}. 
#' The argument will over-ride what is in tox_list.
#' @export
#' @importFrom tidyr gather
#' @importFrom dplyr full_join filter mutate select left_join right_join anti_join
#' @examples
#' path_to_tox <-  system.file("extdata", package="toxEval")
#' file_name <- "OWC_data_fromSup.xlsx"
#' full_path <- file.path(path_to_tox, file_name)
#' 
#' tox_list <- create_toxEval(full_path)
#' \dontrun{
#' ACClong <- get_ACC(tox_list$chem_info$CAS)
#' ACClong <- remove_flags(ACClong)
#' 
#' cleaned_ep <- clean_endPoint_info(endPointInfo)
#' filtered_ep <- filter_groups(cleaned_ep)
#' 
#' chemicalSummary <- get_chemical_summary(tox_list, ACClong, filtered_ep)
#' }                                    
get_chemical_summary <- function(tox_list, ACClong = NULL, filtered_ep = "All", 
                                 chem.data=NULL, chem.site=NULL, 
                                 chem.info=NULL, exclusion=NULL){

  # Getting rid of NSE warnings:
  chnm <- endPoint <- ACC_value <- Value <- `Sample Date` <- SiteID <- ".dplyr"
  EAR <- `Short Name` <- CAS <- Class <- site <- casrn <- groupCol <- ".dplyr"
  
  if(is.null(chem.data)){
    chem.data <- tox_list[["chem_data"]]
  } else {
    chem.data <- rm_em_dash(chem.data)
  }
  
  if(is.null(chem.site)){
    chem.site <- tox_list[["chem_site"]]
  } else {
    chem.site <- rm_em_dash(chem.site)
  }
  
  if(is.null(chem.info)){
    chem.info <- tox_list[["chem_info"]]
  } else {
    chem.info <- rm_em_dash(chem.info)
  }
  
  if(is.null(exclusion)){
    exclusion <- tox_list[["exclusions"]]
  } else {
    exclusion <- rm_em_dash(exclusion)
  }
  
  if(is.null(ACClong)){
    ACClong <- tox_list[["benchmarks"]]
  } else {
    ACClong <- select(ACClong, CAS, chnm, endPoint, ACC_value)
  }
  
  if(class(chem.data$Value) == "character"){
    chem.data$Value <- as.numeric(chem.data$Value)
  }
  
  chemicalSummary <- full_join(ACClong, 
                               select(chem.data, CAS, SiteID, Value, `Sample Date`), by="CAS") %>%
    filter(!is.na(ACC_value)) %>%
    filter(!is.na(Value)) %>%
    mutate(EAR = Value/ACC_value) %>%
    rename(site = SiteID,
           date = `Sample Date`) 
  
  if(all(filtered_ep != "All")){
    chemicalSummary <- chemicalSummary %>%
      select(CAS, chnm, endPoint, site, date, EAR) %>%
      filter(endPoint %in% filtered_ep$endPoint) %>%
      left_join(select(filtered_ep, endPoint, groupCol), by="endPoint")
    
  } else {
    
    chemicalSummary <- chemicalSummary %>%
      select(CAS, chnm, endPoint, site, date, EAR, groupCol)       
  
  }
  
  chemicalSummary <- chemicalSummary  %>%
    left_join(select(chem.site, site=SiteID, `Short Name`),
              by="site") %>%
    left_join(select(chem.info, CAS, Class), by="CAS") %>%
    rename(Bio_category = groupCol,
           shortName = `Short Name`)
  
  if(!is.null(exclusion)){
    chemicalSummary <- exclude_points(chemicalSummary, exclusion)
  }
  
  graphData <- graph_chem_data(chemicalSummary)
  
  orderClass_df <- orderClass(graphData)
 
  orderChem_df <- orderChem(graphData, orderClass_df)
  
  chemicalSummary$chnm <- factor(chemicalSummary$chnm,
                                 levels = unique(orderChem_df$chnm))
  
  chemicalSummary$Class <- factor(chemicalSummary$Class,
                                  levels = rev(levels(orderChem_df$Class)))
  
  return(chemicalSummary)
}


orderClass <- function(graphData){
  
  chnm <- Class <- meanEAR <- median <- max_med <- ".dplyr"
  
  orderClass_df <- graphData %>%
    group_by(chnm, Class) %>%
    summarise(median = quantile(meanEAR[meanEAR != 0],0.5)) %>%
    group_by(Class) %>%
    summarise(max_med = max(median, na.rm = TRUE)) %>%
    arrange(desc(max_med))
  
  return(orderClass_df)
}


orderChem <- function(graphData, orderClass_df){
  
  chnm <- Class <- meanEAR <- median <- ".dplyr"
  
  orderChem_df <- graphData %>%
    group_by(chnm,Class) %>%
    summarise(median = quantile(meanEAR[meanEAR != 0],0.5)) %>%
    data.frame() %>%
    mutate(Class = factor(Class, levels = rev(as.character(orderClass_df$Class))))
  
  orderChem_df$median[is.na(orderChem_df$median)] <- 0
  
  orderChem_df <- arrange(orderChem_df, Class, median)
  
  return(orderChem_df)
}

#' Remove endpoints with specific data quality flags from data
#' 
#' Through the ToxCast program quality assurance procedures, information 
#' is examined and at times, it is necessary to assign a data quality flag 
#' to a specific chemical/assay result. A toxEval user may want to include 
#' or exclude assay results with certain flags depending on the objectives 
#' of a given study. Assay results with specific data quality flags assigned 
#' to them can be removed based on their designated flag with the 
#' \code{remove_flags} function. The flags included in ToxCast, and the associated 
#' flagsShort value (used in the remove_flags function) are as follows:
#' \tabular{ll}{
#' \strong{Flag} \tab \strong{flagsShort}\cr
#' Borderline active* \tab Borderline \cr
#' Only highest conc above baseline, active* \tab OnlyHighest \cr
#' Only one conc above baseline, active \tab OneAbove \cr
#' Noisy data \tab Noisy \cr
#' Hit-call potentially confounded by overfitting \tab HitCall \cr
#' Gain AC50 < lowest conc & loss AC50 < mean conc* \tab GainAC50 \cr
#' Biochemical assay with < 50\% efficacy \tab Biochemical* \cr
#' }
#' Asterisks indicate flags removed in the function as default.
#' 
#' 
#' @param ACClong data frame with columns: casn, chnm, endPoint, and ACC_value
#' @param flagsShort vector of flags to to trigger REMOVAL of chemical:endPoint 
#' combination. Possible values are "Borderline", "OnlyHighest", "OneAbove",
#' "Noisy", "HitCall", "GainAC50", "Biochemical".
#' @export
#' @examples 
#' CAS <- c("121-00-6","136-85-6","80-05-7","84-65-1","5436-43-1","126-73-8")
#' ACClong <- get_ACC(CAS)
#' ACClong <- remove_flags(ACClong)
remove_flags <- function(ACClong, flagsShort = c("Borderline",
                                                 "OnlyHighest",
                                                 "GainAC50",
                                                 "Biochemical")){
  
  match.arg(flagsShort, 
            c("Borderline",
              "OnlyHighest",
              "OneAbove",
              "Noisy",
              "HitCall",
              "GainAC50",
              "Biochemical"),
            several.ok = TRUE)
  
  flags <- ".dplyr"
  
  flag_hits <- select(ACClong, flags) %>%
    mutate(Borderline = grepl("Borderline active", flags),
           Noisy = grepl("Noisy data", flags),
           OneAbove = grepl("Only one conc above baseline", flags),
           OnlyHighest = grepl("Only highest conc above baseline", flags),
           Biochemical = grepl("Biochemical assay with", flags),
           GainAC50 = grepl("Gain AC50", flags),
           HitCall = grepl("potentially confounded by overfitting", flags)) %>%
    select(-flags)
  
  ACClong <- ACClong[rowSums(flag_hits[flagsShort]) == 0,]

  return(ACClong)
  
  # So, with the defaults, we are taking out:
  # c("Borderline active",
  #   "Only highest conc above baseline, active",
  #   "Gain AC50 < lowest conc & loss AC50 < mean conc", 
  #   "Biochemical assay with < 50% efficacy")
  # We are leaving in with the defaults:
  # c("Hit-call potentially confounded by overfitting",
  #   "Only one conc above baseline, active",
  #   "Noisy data")
  
}


exclude_points <- function(chemicalSummary, exclusion){
  
  CAS <- endPoint <- casrn <- ".dplyr"
  
  exclude_chem <- exclusion$CAS[is.na(exclusion$endPoint)]
  exclude_ep <- exclusion$endPoint[is.na(exclusion$CAS)]
  
  exclude_combo <- exclusion %>%
    filter(!is.na(CAS),
           !is.na(endPoint))
  
  chem_filtered <- chemicalSummary %>%
    filter(!(CAS %in% exclude_chem)) %>%
    filter(!(endPoint %in% exclude_ep)) 
  
  if(nrow(exclude_combo) > 0){
    chem_filtered <- chem_filtered %>%
      anti_join(exclude_combo, by=c("CAS","endPoint"))
  }

  return(chem_filtered)
}
