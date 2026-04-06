#----------------------------------------------------------------------------------------
# File: 000_startHere.R
# Project: Cloze_Prolific
# Author: Mykel Brinkerhoff
# Date: 2026-04-06 (M)
# Description: What does this script do?
#   - loads the required packages
# Usage:
#   Rscript 000_startHere.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------
# Install packages
pkgs <- c(
  "dplyr",
  "tidyr",
  "readr",
  "stringr",
  "reshape2",
  "ggplot2",
  "here",
  "remotes",
  "ggokabeito"
)

# renv::install(pkgs)

### Load helper packages
library(dplyr) # for data manipulation, graphic, and data wrangling
library(tidyr) # for data manipulation
library(readr) # loading in data
library(stringr) # look for stuff in strings
library(reshape2) # for data manipulation
library(ggplot2) # for plotting
library(here) # for creating pathways relative to the top-level directory
library(remotes) # allows accessing github
# library(joeyr) # needed for the find_outliers function
library(ggokabeito) # colorblind friendly color based on Okabe-Ito scheme
