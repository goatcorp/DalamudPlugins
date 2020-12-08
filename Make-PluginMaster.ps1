$ErrorActionPreference = 'SilentlyContinue'

$output = New-Object Collections.Generic.List[object]
$notInclude = "GoodMemory", "SlideCast", "XIVStats", "TitleEdit", "VoidList", "Globetrotter", "Visibility", "SimpleTweaksPlugin";

$counts = Get-Content "downloadcounts.json" | ConvertFrom-Json

$thisPath = Get-Location

$table = ""

Get-ChildItem -Path plugins -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json

    if ($notInclude.Contains($content.InternalName)) { 
    	$content | add-member -Name "IsHide" -value "True" -MemberType NoteProperty
    }
    else
    {
    	$content | add-member -Name "IsHide" -value "False" -MemberType NoteProperty
        
        $newDesc = $content.Description -replace "\n", "<br>"
    	$table = $table + "| " + $content.Author + " | " + $content.Name + " | " + $newDesc + " |`n"
    }

    $testingPath = Join-Path $thisPath -ChildPath "testing" | Join-Path -ChildPath $content.InternalName | Join-Path -ChildPath $_.Name
    if ($testingPath | Test-Path)
    {
        $testingContent = Get-Content $testingPath | ConvertFrom-Json
        $content | add-member -Name "TestingAssemblyVersion" -value $testingContent.AssemblyVersion -MemberType NoteProperty
    }
    $content | add-member -Name "IsTestingExclusive" -value "False" -MemberType NoteProperty

    $dlCount = $counts | Select-Object -ExpandProperty $content.InternalName | Select-Object -ExpandProperty "count" 
    if ($dlCount -eq $null){
        $dlCount = 0;
    }
    $content | add-member -Name "DownloadCount" $dlCount -MemberType NoteProperty

    $output.Add($content)
}

Get-ChildItem -Path testing -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json

    if ($notInclude.Contains($content.InternalName)) { 
    	$content | add-member -Name "IsHide" -value "True" -MemberType NoteProperty
    }
    else
    {
    	$content | add-member -Name "IsHide" -value "False" -MemberType NoteProperty
    	# $table = $table + "| " + $content.Author + " | " + $content.Name + " | " + $content.Description + " |`n"
    }

    $dlCount = 0;
    $content | add-member -Name "DownloadCount" $dlCount -MemberType NoteProperty

    if (($output | Where-Object {$_.InternalName -eq $content.InternalName}).Count -eq 0)
    {
        $content | add-member -Name "TestingAssemblyVersion" -value $content.AssemblyVersion -MemberType NoteProperty
        $content | add-member -Name "IsTestingExclusive" -value "True" -MemberType NoteProperty
    
        $output.Add($content)
    }
}

$outputStr = $output | ConvertTo-Json
Write-Output $outputStr

Out-File -FilePath .\pluginmaster.json -InputObject $outputStr

$template = Get-Content -Path mdtemplate.txt
$template = $template + $table
Out-File -FilePath .\plugins.md -InputObject $template
