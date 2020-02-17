$output = New-Object Collections.Generic.List[object]

Get-ChildItem -Path plugins -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json
    echo $content
    $output.Add($content)
}

$outputStr = $output | ConvertTo-Json
echo $outputStr

Out-File -FilePath .\pluginmaster.json -InputObject $outputStr