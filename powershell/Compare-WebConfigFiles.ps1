param (
     [string]$file1 = "G:\GIT\self\Resume\powershell\web.Config"
    ,[string]$file2 = "G:\GIT\self\Resume\powershell\web copy.Config"
)
function displayNodes ($node, $path, $list, $display) {
    $xpath = $path
    $localList = $list
    if ($node.NodeType -eq "Comment") {
    }
    else {
        $node_name = $node.LocalName
        $node_type = $node.NodeType
        $xpath = $xpath + "/" + $node_name
        if ($display) {
            Write-Output "Type[$node_type] | Name[$node_name] | Path[$xpath]"
        }
        $list.Add($xpath) | Out-Null
    }

    if ($null -ne $node.Attributes) {
        $node_attributes = $node.Attributes
        foreach($attribute in $node_attributes) {
            $attribute_name = $attribute.Name
            $attribute_value = $attribute.Value
            $attributePath = $xpath + "/@" + $attribute_name
            if ($display) {
                Write-Output "`tAttribute Name[$attribute_name] | Attribute Value[$attribute_value] | Path[$attributePath]"
            }
            $entry = $attributePath + "," + $attribute_value
            $list.Add($entry) | Out-Null
        }
    }

    $node_children = $node.ChildNodes
    foreach($child in $node_children) {
        displayNodes $child $xpath $localList
    }
}
try {
    $xmlList1 = New-Object -TypeName 'System.Collections.ArrayList'
    $xmlList2 = New-Object -TypeName 'System.Collections.ArrayList'
    
    [xml]$xml = Get-Content -Path $file1
    $rootNode = $xml.DocumentElement
    displayNodes $rootNode "" $xmlList1 $false
    
    [xml]$xml2 = Get-Content -Path $file2
    $rootNode2 = $xml2.DocumentElement
    displayNodes $rootNode2 "" $xmlList2 $false
    
    # https://stackoverflow.com/questions/8609204/union-and-intersection-in-powershell
    $union = Compare-Object $xmlList1 $xmlList2 -PassThru -IncludeEqual
    $intersection = Compare-Object $xmlList1 $xmlList2 -PassThru
    
    #Write-Output $union
    foreach($mismatch in $intersection) {
        $side = $mismatch | Select-Object -ExpandProperty "SideIndicator"
        if ($side -eq "=>") {
            Write-Output "File: $file2 | Difference: $mismatch"
        }
        else {
            Write-Output "File: $file1 | Difference: $mismatch"
        }
    }
   
}
catch {
    Write-Error $_.Exception.Message
}
