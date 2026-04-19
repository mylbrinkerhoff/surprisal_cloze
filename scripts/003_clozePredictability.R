#----------------------------------------------------------------------------------------
# File: 003_clozePredictability.R
# Project: Cloze_Prolific
# Author: Mykel Brinkerhoff
# Date: 2026-04-12 (Su)
# Description: What does this script do?
#
# Usage:
#   Rscript 003_clozePredictability.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# Unique ids for each sentence as they appear in the experiment, check if the entry is the dictionary
responses <- cloze |>
  dplyr::mutate(
    sentence_id = match(text, unique(text)),
    in_dictionary = response %in% dictionary$entry
  )

# Dataframe showing each sentence with its sentence_id
sentences <- responses |>
  dplyr::select(sentence_id, text) |>
  dplyr::distinct()

# Calculate the Levenshtein distance from the dictionary entry
# 0 = exact match;
# 1 = minor spelling difference,
# 2 = major spelling or morphological difference,
# 3 or more = not related

# generate distance matrix
dist_mat <- stringdist::stringdistmatrix(
  responses$response,
  dictionary$entry,
  method = "lv"
)

responses <- responses |>
  dplyr::mutate(
    min_dist = apply(dist_mat, 1, min),
    word = min_dist < 3,
    word_target = lev_dist < 3
  )

#Frequency of response by sentence
freq_table <- responses |>
  dplyr::group_by(sentence_id, response) |>
  dplyr::summarise(
    n = dplyr::n(),
    .groups = "drop"
  )

# find the total number of responses for each sentence and K is the number of distinct responses
totals <- responses |>
  dplyr::group_by(sentence_id) |>
  dplyr::summarise(
    total = dplyr::n(),
    K = dplyr::n_distinct(response),
    .groups = "drop"
  )

# Calculate the probability and the smooth probability
cloze_table <- freq_table |>
  dplyr::left_join(totals, by = "sentence_id") |>
  dplyr::mutate(
    prob_raw = n / total,
    prob_smooth = (n + 1) / (total + 1 * K)
  )

# Calculate the target cloze probability
target_cloze <- cloze_table |>
  dplyr::inner_join(
    responses |>
      dplyr::distinct(sentence_id, target),
    by = "sentence_id"
  ) |>
  dplyr::filter(stringdist::stringdist(response, target, method = "lv") < 3) |>
  dplyr::transmute(
    sentence_id,
    target,
    target_prob_raw = prob_raw,
    target_prob_smooth = prob_smooth
  )

# Calculate surprisal
cloze_table <- cloze_table |>
  dplyr::mutate(
    surprisal_raw = -log(prob_raw),
    surprisal_smooth = -log(prob_smooth)
  )

#calculate the target surprisal
target_surprisal <- cloze_table |>
  dplyr::inner_join(
    responses |>
      dplyr::distinct(sentence_id, target),
    by = "sentence_id"
  ) |>
  dplyr::filter(stringdist::stringdist(response, target, method = "lv") < 3) |>
  dplyr::transmute(
    sentence_id,
    target,
    target_surprisal_raw = surprisal_raw,
    target_surprisal_smooth = surprisal_smooth
  )


# Calculate the entropy and smoothed entropy
entropy_table <- cloze_table |>
  dplyr::mutate(
    entropy_component_raw = prob_raw * log(prob_raw),
    entropy_component_smooth = prob_smooth * log(prob_smooth)
  ) |>
  dplyr::group_by(sentence_id) |>
  dplyr::summarise(
    entropy_raw = -sum(entropy_component_raw),
    entropy_smooth = -sum(entropy_component_smooth),
    .groups = "drop"
  )

# Calculate the lexical competition
competition_table <- cloze_table |>
  dplyr::group_by(sentence_id) |>
  dplyr::mutate(
    rank = dplyr::dense_rank(-prob_smooth)
  ) |>
  dplyr::filter(rank <= 2) |>
  dplyr::summarise(
    top1 = max(prob_smooth),
    top2 = dplyr::nth(sort(prob_smooth, decreasing = TRUE), 2),
    competition = top1 - top2,
    .groups = "drop"
  )

# combine the datasets
final_data <- target_cloze |>
  dplyr::left_join(
    target_surprisal,
    by = c("sentence_id", "target"),
    relationship = "many-to-many"
  ) |>
  dplyr::left_join(
    entropy_table,
    by = "sentence_id",
    relationship = "many-to-many"
  ) |>
  dplyr::left_join(
    competition_table,
    by = "sentence_id",
    relationship = "many-to-many"
  )
