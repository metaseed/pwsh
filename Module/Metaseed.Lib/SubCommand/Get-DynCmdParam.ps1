function Get-DynCmdParam {
    param (
        [string]$cacheName,
        [string]$CommandFolder,
        [string]$Command,
        [string]$filter = '*.ps1'
    )

    if (-not $Command) {
        return
    }

    $file = Find-CmdItem $cacheName $CommandFolder $Command $filter

    if ($null -eq $file) {
        return
    }

    $rp = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $c = Get-Command -Name $file  -CommandType ExternalScript
    if (!$c.Parameters -or !$c.Parameters.Count) { return $rp }

    $pn = 'Verbose', 'Debug', 'ErrorAction', 'InformationAction', 'InformationVariable', 'WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
    foreach ($pv in $c.Parameters.Values) {
        # filter out common parameters
        if ($pn -notcontains $pv.Name) {
            # shift the ParameterAttribute's Position value, because we have 's' at first position
            for ($i = 0; $i -lt $pv.Attributes.Count; $i++) {
                $attr = $pv.Attributes[$i]
                if ($attr -is [System.Management.Automation.ParameterAttribute]) {
                    $position = $attr.Position
                    if ($position -ge 0) {
                        # only increase one time, otherwise the position will be increased at every command session, strange: the value is kept between command-input session
                        # to test use: dd create-pullrequest 1810574
                        # so we creat a new attribute with the same value, and just modify the Position value
                        $newAttr = New-Object System.Management.Automation.ParameterAttribute
                        # dd command para0 para1
                        $newAttr.Position = $position + 1
                        # Write-Host "shift position of $pv.Name from $position to $($newAttr.Position)"
                        if ($attr.Mandatory) { $newAttr.Mandatory = $attr.Mandatory }
                        if ($attr.ValueFromPipeline) { $newAttr.ValueFromPipeline = $attr.ValueFromPipeline }
                        if ($attr.ValueFromPipelineByPropertyName) { $newAttr.ValueFromPipelineByPropertyName = $attr.ValueFromPipelineByPropertyName }
                        if ($attr.ValueFromRemainingArguments) { $newAttr.ValueFromRemainingArguments = $attr.ValueFromRemainingArguments }
                        if ($attr.HelpMessage) { $newAttr.HelpMessage = $attr.HelpMessage }
                        if ($attr.HelpMessageBaseName) { $newAttr.HelpMessageBaseName = $attr.HelpMessageBaseName }
                        if ($attr.HelpMessageResourceId) { $newAttr.HelpMessageResourceId = $attr.HelpMessageResourceId }
                        if ($attr.ParameterSetName) { $newAttr.ParameterSetName = $attr.ParameterSetName }
                        if ($attr.DontShow) { $newAttr.DontShow = $attr.DontShow }
                        if ($attr.ExperimentAction) { $newAttr.ExperimentAction = $attr.ExperimentAction }
                        if ($attr.ExperimentName) { $newAttr.ExperimentName = $attr.ExperimentName }
                        $pv.Attributes[$i] = $newAttr
                    }
                }
            }
            $rp.Add($pv.Name, (New-Object System.Management.Automation.RuntimeDefinedParameter $pv.Name, $pv.ParameterType, $pv.Attributes))
        }
    }
    return $rp
}