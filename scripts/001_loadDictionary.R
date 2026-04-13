#----------------------------------------------------------------------------------------
# File: 001_loadDictionary.R
# Project: Cloze_Prolific
# Author: Mykel Brinkerhoff
# Date: 2026-04-12 (Su)
# Description: What does this script do?
#   - Loads the CMU dictionary for future use
#
# Usage:
#   Rscript .R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------
# load in the cmu dictionary

dictionary <- readr::read_csv(here::here("data", "raw", "cmudict.csv"))

dictionary <- dictionary |>
  tidyr::unite(
    pronunciation,
    2:29,
    sep = " ",
    na.rm = TRUE
  )
