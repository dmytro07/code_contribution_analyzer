#!/bin/bash

# Function to calculate the net lines of code for a given author
get_net_loc() {
    local author="$1"
    local net_loc=0

    # Get the log of changes for the author and process each line
    while IFS=$'\t' read -r additions deletions _; do
        if [[ "$additions" =~ ^[0-9]+$ ]] && [[ "$deletions" =~ ^[0-9]+$ ]]; then
            net_loc=$((net_loc + additions - deletions))
        fi
    done < <(git log --author="$author" --pretty=tformat: --numstat)

    echo "$net_loc"
}

# Get the list of contributors
contributors=$(git log --pretty="%aN" | sort | uniq)

# Initialize total lines of code variable
total_lines_of_code=0

# Initialize arrays for storing contributors and their LOC
contributor_names=()
contributor_locs=()

# Loop through each contributor and count their lines of code
while IFS= read -r contributor; do
    echo "Processing $contributor..." # Debugging line
    lines_of_code=$(get_net_loc "$contributor")
    contributor_names+=("$contributor")
    contributor_locs+=("$lines_of_code")
    echo "$contributor: $lines_of_code"
    total_lines_of_code=$((total_lines_of_code + lines_of_code))
done <<< "$contributors"

# Calculate and display percentage for each contributor
echo ""
echo "Percentage of code written by each contributor:"
for i in "${!contributor_names[@]}"; do
    contributor="${contributor_names[$i]}"
    lines_of_code="${contributor_locs[$i]}"
    if [[ $total_lines_of_code -eq 0 ]]; then
        percentage=0
    else
        percentage=$(echo "scale=2; ($lines_of_code / $total_lines_of_code) * 100" | bc)
    fi
    echo "$contributor: $percentage%"
done
