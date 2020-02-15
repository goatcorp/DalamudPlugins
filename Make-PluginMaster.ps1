$output = '{"plugins":['

Get-ChildItem -Path plugins -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName
    $output += $content + ","
}

$output += ']}'

Out-File -FilePath .\pluginmaster.json -InputObject $output