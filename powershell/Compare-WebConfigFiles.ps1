param (
    [string]$file1 = "C:\LCD\GIT\self\Resume\powershell\web.Config"
    , [string]$file2 = "C:\LCD\GIT\self\Resume\powershell\web copy.Config"
)
function displayNodes ($node, $path, $list, $display, $fileName) {
    $localFileName = $fileName
    $xpath = $path
    $localList = $list
    $localDisplay = $display
    if ($node.NodeType -eq "Comment") {
    }
    else {
        $node_name = $node.LocalName
        $node_type = $node.NodeType
        $xpath = $xpath + "/" + $node_name
        if ($localDisplay) {
            Write-Output "Path[$xpath] | Type[$node_type] | Name[$node_name]"
        }
    }

    if ($null -ne $node.Attributes) {
        $node_attributes = $node.Attributes
        $attributeList = New-Object -TypeName 'System.Collections.ArrayList'

        foreach ($attribute in $node_attributes) {
            $attribute_name = $attribute.Name
            $attribute_value = $attribute.Value
            $attributePath = $xpath + "/@" + $attribute_name
            if ($localDisplay) {
                Write-Output "Path[$attributePath] | Attribute Name[$attribute_name] | Attribute Value[$attribute_value]"
            }
            $xmlObject = New-Object -TypeName PSObject -Property @{
                PK_Attribute             = "$node_type|$node_name|$attributePath|$attribute_name|$attribute_value"
                FileName       = "$localFileName"
                NodeType       = "$node_type"
                NodeName       = "$node_name"
                rootXpath      = "$xpath"
                xPath          = "$attributePath"
                AttributeName  = "$attribute_name"
                AttributeValue = "$attribute_value"
            }
            $attributeList.Add($xmlObject) | Out-Null
        }
        if($attributeList.Count -ne 0) {
            $PK = ""
            if ($attributeList.Count -gt 1) {
                [System.Collections.ArrayList]$attributeList = $attributeList | Sort-Object -Property AttributeName 
            }
            foreach($attribute in $attributeList) {
                if ($PK -eq "") {
                    $PK = $PK + $attribute.rootXpath + "/@"
                }
                $PK = $PK + "|$($attribute.AttributeName)[$($attribute.AttributeValue)]"
            }
            $element = New-Object -TypeName PSObject -Property @{
                PK = "$PK"
                AttributeList = $attributeList
            }
            $list.Add($element) | Out-Null
        }
    }

    $node_children = $node.ChildNodes
    foreach ($child in $node_children) {
        displayNodes $child $xpath $localList $localDisplay $localFileName
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
    
    $xmlCompareList1 = $xmlList1 | Select-Object -Property "PK"
    foreach($key in $xmlCompareList1) {
        Write-Output $key.PK
    }
    $xmlCompareList2 = $xmlList2 | Select-Object -Property "PK"

    $left = New-Object -TypeName 'System.Collections.ArrayList'
    $both = New-Object -TypeName 'System.Collections.ArrayList'
    $right = New-Object -TypeName 'System.Collections.ArrayList'

    foreach ($key in $xmlCompareList1) {
        $match = $false
        $pk = $key.PK
        foreach ($compareKey in $xmlCompareList2) {
            $pk2 = $compareKey.PK
            if ($pk -eq $pk2) {
                $both.Add($pk) | Out-Null
                $match = $true
                break;
            }
        }
        if (-not($match)) {
            $left.Add($pk) | Out-Null
        }
    }

    foreach ($key in $xmlCompareList2) {
        $match = $false
        $pk = $key.PK
        foreach ($compareKey in $xmlCompareList1) {
            $pk2 = $compareKey.PK
            if ($pk -eq $pk2) {
                $match = $true
                break;
            }
        }
        if (-not($match)) {
            $right.Add($pk) | Out-Null
        }
    }
    
    Write-Output "---------------------------------------"
    Write-Output "File: $file1"
    Write-Output "---"
    foreach($line in $left) {
        Write-Output $line
    }
    Write-Output "---------------------------------------"
    Write-Output "File: $file2"
    Write-Output "---"
    foreach($line in $right) {
        Write-Output $line
    }

    
  
}
catch {
    Write-Error $_.Exception.Message
}
