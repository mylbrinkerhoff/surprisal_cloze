#----------------------------------------------------------------------------------------
# File: 002_loadExperiment.R
# Project: Cloze_Prolific
# Author: Mykel Brinkerhoff
# Date: 2026-04-12 (Su)
# Description: What does this script do?
#   - Loads in the results of the cloze experiment and formates it
# Usage:
#   Rscript 002_loadExperiment.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# path to CSV files
path <- here::here("data", "raw", "cloze_results")

# List all CSV files in the directory
csv_files <- list.files(path = path, pattern = "\\.csv$", full.names = TRUE)

# Read all CSV files into a list of data frames
data_list <- lapply(csv_files, read.csv)

# Optionally, combine all data frames into one data frame
combined_data <- do.call(rbind, data_list)

cloze <- combined_data |>
    dplyr::mutate(
        target = stringr::str_extract_all(
            text,
            "(?<=%)[^%]+(?=%)",
            simplify = TRUE
        ),
        response = stringr::str_replace_all(
            response,
            pattern = '\\[|\\]|"',
            replacement = ''
        )
    ) |>
    dplyr::select(
        -c('study_id', 'session_id')
    ) |>
    dplyr::filter(block == "main")
