function Get-NetLOC {
    param(
        [string] $author
    )
    $netLOC = 0
    $gitLog = git log --author="$author" --pretty=tformat: --numstat
    foreach ($line in $gitLog) {
        if ($line -match '(\d+)\s+(\d+)\s+') {
            $additions = [int]$Matches[1]
            $deletions = [int]$Matches[2]
            $netLOC += $additions - $deletions
        }
    }
    return $netLOC
}

# Get the list of contributors
$contributors = git log --pretty="%aN" | Sort-Object | Get-Unique

# Initialize total lines of code variable
$total_lines_of_code = 0

# Loop through each contributor and count their lines of code
foreach ($contributor in $contributors) {
    $lines_of_code = Get-NetLOC -author $contributor
    Write-Host "${contributor}: $lines_of_code"
    $total_lines_of_code += $lines_of_code
}

# Calculate and display percentage for each contributor
Write-Host ""
Write-Host "Percentage of code written by each contributor:"
foreach ($contributor in $contributors) {
    $lines_of_code = Get-NetLOC -author $contributor
    if ($total_lines_of_code -eq 0) {
        $percentage = 0
    }
    else {
        $percentage = ($lines_of_code / $total_lines_of_code) * 100
    }
    Write-Host "${contributor}: $percentage%"
}
