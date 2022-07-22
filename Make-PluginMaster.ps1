$ErrorActionPreference = 'SilentlyContinue'

$output = New-Object Collections.Generic.List[object]
$notInclude = "sdgfdsgfgdfs", "sdfgdfg", "XIVStats", "bffbbf", "VoidList", "asdfsad", "sdfgdfsg", "vrgnddgv";

$counts = Get-Content "downloadcounts.json" | ConvertFrom-Json
$categoryFallbacksMap = Get-Content "categoryfallbacks.json" | ConvertFrom-Json

$pluginBlacklistUrl = "https://goatcorp.github.io/DalamudAssets/UIRes/bannedplugin.json"

$wc = New-Object system.Net.WebClient
$blackList = $wc.downloadString($pluginBlacklistUrl) | ConvertFrom-Json

$dlTemplateInstall = "https://kamori.goats.dev/Plugin/Download/{0}?isUpdate=False&isTesting={1}&branch=api6"
$dlTemplateUpdate = "https://raw.githubusercontent.com/goatcorp/DalamudPlugins/api6/{0}/{1}/latest.zip"

$apiLevel = 6

$thisPath = Get-Location

$table = ""

function Is-Banned {
    param (
        $PluginName,
        $AssemblyVersion
    )

    foreach ($blackItem in $blackList) {
        if ($blackItem.Name -eq $PluginName) {
            if ([System.Version]$blackItem.AssemblyVersion -ge [System.Version]$AssemblyVersion) {
                return $true
            }
        }
    }
    return $false
}

Get-ChildItem -Path plugins -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json

    $isBanned = Is-Banned -PluginName $content.InternalName -AssemblyVersion $content.AssemblyVersion
    if ($notInclude.Contains($content.InternalName) -or $isBanned) { 
    	$content | add-member -Force -Name "IsHide" -value "True" -MemberType NoteProperty
    }
    else
    {
    	$content | add-member -Force -Name "IsHide" -value "False" -MemberType NoteProperty
        
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
        $content | add-member -Force -Name "TestingAssemblyVersion" -value $testingContent.AssemblyVersion -MemberType NoteProperty
    }
    $content | add-member -Force -Name "IsTestingExclusive" -value "False" -MemberType NoteProperty

    $dlCount = $counts | Select-Object -ExpandProperty $content.InternalName
    if ($dlCount -eq $null){
        $dlCount = 0;
    }
    $content | add-member -Force -Name "DownloadCount" $dlCount -MemberType NoteProperty

    if ($content.CategoryTags -eq $null) {
    	$content | Select-Object -Property * -ExcludeProperty CategoryTags
    
        $fallbackCategoryTags = $categoryFallbacksMap | Select-Object -ExpandProperty $content.InternalName
        if ($fallbackCategoryTags -ne $null) {
			$content | add-member -Force -Name "CategoryTags" -value @() -MemberType NoteProperty
			$content.CategoryTags += $fallbackCategoryTags
        }
    }

    $internalName = $content.InternalName
    
    $updateDate = git log -1 --pretty="format:%ct" plugins/$internalName/latest.zip
    if ($updateDate -eq $null){
        $updateDate = 0;
    }
    $content | add-member -Force -Name "LastUpdate" $updateDate -MemberType NoteProperty

    $installLink = $dlTemplateInstall -f $internalName, "False"
    $content | add-member -Force -Name "DownloadLinkInstall" $installLink -MemberType NoteProperty
    
    $installLink = $dlTemplateInstall -f $internalName, "True"
    $content | add-member -Force -Name "DownloadLinkTesting" $installLink -MemberType NoteProperty
    
    $updateLink = $dlTemplateUpdate -f "plugins", $internalName
    $content | add-member -Force -Name "DownloadLinkUpdate" $updateLink -MemberType NoteProperty

    $output.Add($content)
}

Get-ChildItem -Path testing -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json

    $isBanned = Is-Banned -PluginName $content.InternalName -AssemblyVersion $content.AssemblyVersion
    if ($notInclude.Contains($content.InternalName) -or $isBanned) { 
    	$content | add-member -Force -Name "IsHide" -value "True" -MemberType NoteProperty
    }
    else
    {
    	$content | add-member -Force -Name "IsHide" -value "False" -MemberType NoteProperty
    	# $table = $table + "| " + $content.Author + " | " + $content.Name + " | " + $content.Description + " |`n"
    }

    $dlCount = 0;
    $content | add-member -Force -Name "DownloadCount" $dlCount -MemberType NoteProperty

    if (($output | Where-Object {$_.InternalName -eq $content.InternalName}).Count -eq 0)
    {
        $content | add-member -Force -Name "TestingAssemblyVersion" -value $content.AssemblyVersion -MemberType NoteProperty
        $content | add-member -Force -Name "IsTestingExclusive" -value "True" -MemberType NoteProperty

		if ($content.CategoryTags -eq $null) {
			$content | Select-Object -Property * -ExcludeProperty CategoryTags
		
			$fallbackCategoryTags = $categoryFallbacksMap | Select-Object -ExpandProperty $content.InternalName
			if ($fallbackCategoryTags -ne $null) {
				$content | add-member -Force -Name "CategoryTags" -value @() -MemberType NoteProperty
				$content.CategoryTags += $fallbackCategoryTags
			}
		}

        $internalName = $content.InternalName
        
        $updateDate = git log -1 --pretty="format:%ct" testing/$internalName/latest.zip
        if ($updateDate -eq $null){
            $updateDate = 0;
        }
        $content | add-member -Force -Name "LastUpdate" $updateDate -MemberType NoteProperty

        $installLink = $dlTemplateInstall -f $internalName, "True"
        $content | add-member -Force -Name "DownloadLinkInstall" $installLink -MemberType NoteProperty
        
        $installLink = $dlTemplateInstall -f $internalName, "True"
        $content | add-member -Force -Name "DownloadLinkTesting" $installLink -MemberType NoteProperty
    
        $updateLink = $dlTemplateUpdate -f "plugins", $internalName
        $content | add-member -Force -Name "DownloadLinkUpdate" $updateLink -MemberType NoteProperty
    
        $output.Add($content)
    }
}

$outputStr = $output | ConvertTo-Json

Out-File -FilePath .\pluginmaster.json -InputObject $outputStr

$template = Get-Content -Path mdtemplate.txt
$template = $template + $table
Out-File -FilePath .\plugins.md -InputObject $template
