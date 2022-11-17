# Purpose: Remove vote_countes that are less than 55 minutes appart
# Author: Mario Frei, 2022
# Status: Under development
# Project: Cozie
# Experiemnt: Orenth


def keep_valid_votes(df_input):
  threshold = 55  # Cut of threshold for validity. If time difference is smaller than 55min then the vote_count is rejected.
  df_output = df_input.copy()
  df = df_input[df_input.vote_count.notna()]

  timestamp_previous_valid = -1
  for timestamp, row in df.iterrows():

    # Skip first entry
    if timestamp_previous_valid==-1:
      timestamp_previous_valid = timestamp
      continue

    # Compute time difference between vote_counts
    timestamp_diff = (timestamp-timestamp_previous_valid).total_seconds()/60
    if timestamp_diff>threshold:
      timestamp_previous_valid = timestamp
    else: 
      df_output = df_output.drop(timestamp)

  return df_output.copy()