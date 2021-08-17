$ErrorActionPreference = 'SilentlyContinue'

$output = New-Object Collections.Generic.List[object]
$notInclude = "sdgfdsgfgdfs", "sdfgdfg", "XIVStats", "bffbbf", "VoidList", "asdfsad", "sdfgdfsg", "vrgnddgv";

$counts = Get-Content "downloadcounts.json" | ConvertFrom-Json

$dlTemplateInstall = "https://us-central1-xl-functions.cloudfunctions.net/download-plugin/?plugin={0}&isUpdate=False&isTesting={1}&branch=master"
$dlTemplateUpdate = "https://us-central1-xl-functions.cloudfunctions.net/download-plugin/?plugin={0}&isUpdate=True&isTesting={1}&branch=master"

$apiLevel = 3

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
        $newDesc = $newDesc -replace "\|", "I"
        
        if ($content.DalamudApiLevel -eq $apiLevel) {
            if ($content.RepoUrl) {
                $table = $table + "| " + $content.Author + " | [" + $content.Name + "](" + $content.RepoUrl + ") | " + $newDesc + " |`n"
            }
            else {
                $table = $table + "| " + $content.Author + " | " + $content.Name + " | " + $newDesc + " |`n"
            }
        }
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

    $internalName = $content.InternalName
    
    $updateDate = git log -1 --pretty="format:%ct" plugins/$internalName/latest.zip
    if ($updateDate -eq $null){
        $updateDate = 0;
    }
    $content | add-member -Name "LastUpdate" $updateDate -MemberType NoteProperty

    $installLink = $dlTemplateInstall -f $internalName, "False"
    $content | add-member -Name "DownloadLinkInstall" $installLink -MemberType NoteProperty
    
    $installLink = $dlTemplateInstall -f $internalName, "True"
    $content | add-member -Name "DownloadLinkTesting" $installLink -MemberType NoteProperty
    
    $updateLink = $dlTemplateUpdate -f $internalName, "False"
    $content | add-member -Name "DownloadLinkUpdate" $updateLink -MemberType NoteProperty

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

        $internalName = $content.InternalName
        
        $updateDate = git log -1 --pretty="format:%ct" testing/$internalName/latest.zip
        if ($updateDate -eq $null){
            $updateDate = 0;
        }
        $content | add-member -Name "LastUpdate" $updateDate -MemberType NoteProperty

        $installLink = $dlTemplateInstall -f $internalName, "True"
        $content | add-member -Name "DownloadLinkInstall" $installLink -MemberType NoteProperty
        
        $installLink = $dlTemplateInstall -f $internalName, "True"
        $content | add-member -Name "DownloadLinkTesting" $installLink -MemberType NoteProperty
    
        $updateLink = $dlTemplateUpdate -f $internalName, "True"
        $content | add-member -Name "DownloadLinkUpdate" $updateLink -MemberType NoteProperty
    
        $output.Add($content)
    }
}

$outputStr = $output | ConvertTo-Json
Write-Output $outputStr

Out-File -FilePath .\pluginmaster.json -InputObject $outputStr

$template = Get-Content -Path mdtemplate.txt
$template = $template + $table
Out-File -FilePath .\plugins.md -InputObject $template
