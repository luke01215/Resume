param (
     [string]$file1 = "C:\LCD\Test\ConfigFiles\PNS\DEV\web.Config"
    ,[string]$file2 = "C:\LCD\Test\ConfigFiles\PNS\UAT\web.Config"
)
function displayNodes ($node, $path, $list, $display, $fileName) {
    $localFileName = $fileName
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
        $xmlObject = New-Object -TypeName PSObject -Property @{
            PK = "$node_type|$node_name|$xpath"
            FileName = "$localFileName"
            NodeType = "$node_type"
            NodeName = "$node_name"
            xPath = "$xpath"
            AttributeName = ""
            AttributeValue = ""
        }
        $list.Add($xmlObject) | Out-Null
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
            $xmlObject = New-Object -TypeName PSObject -Property @{
                PK = "$node_type|$node_name|$attributePath|$attribute_name|$attribute_value"
                FileName = "$localFileName"
                NodeType = "$node_type"
                NodeName = "$node_name"
                xPath = "$attributePath"
                AttributeName = "$attribute_name"
                AttributeValue = "$attribute_value"
            }
            $list.Add($xmlObject) | Out-Null
        }
    }

    $node_children = $node.ChildNodes
    foreach($child in $node_children) {
        displayNodes $child $xpath $localList $false $localFileName
    }
}
try {
    $xmlList1 = New-Object -TypeName 'System.Collections.ArrayList'
    $xmlList2 = New-Object -TypeName 'System.Collections.ArrayList'
    
    [xml]$xml = Get-Content -Path $file1
    $rootNode = $xml.DocumentElement
    displayNodes $rootNode "" $xmlList1 $false $file1
    
    [xml]$xml2 = Get-Content -Path $file2
    $rootNode2 = $xml2.DocumentElement
    displayNodes $rootNode2 "" $xmlList2 $false $file2
    
    # https://stackoverflow.com/questions/8609204/union-and-intersection-in-powershell
    $xmlCompareList1 = $xmlList1 | Select-Object -ExcludeProperty "FileName"
    $xmlCompareList2 = $xmlList2 | Select-Object -ExcludeProperty "FileName"

    #$union = Compare-Object $xmlCompareList1 $xmlCompareList2 -PassThru -IncludeEqual
    $intersection = Compare-Object $xmlCompareList1 $xmlCompareList2 -PassThru
    
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
