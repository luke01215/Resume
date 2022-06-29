param (
    [string]$fileName = "G:\GIT\self\Resume\powershell\web.Config"
)
function displayNodes ($node, $path) {
    $xpath = $path
    if ($node.NodeType -eq "Comment") {
    }
    else {
        $node_name = $node.Name
        $node_type = $node.NodeType
        $xpath = $xpath + "/" + $node_name
        Write-Output "Type[$node_type] | Name[$node_name] | Path[$xpath]"
    }

    if ($null -ne $node.Attributes) {
        $node_attributes = $node.Attributes
        foreach($attribute in $node_attributes) {
            $attribute_name = $attribute.Name
            $attribute_value = $attribute.Value
            $attributePath = $xpath + "/@" + $attribute_name
            Write-Output "`tAttribute Name[$attribute_name] | Attribute Value[$attribute_value] | Path[$attributePath]"
        }
    }

    $node_children = $node.ChildNodes
    foreach($child in $node_children) {
        displayNodes $child $xpath
    }
}

[xml]$xml = Get-Content -Path $fileName
$rootNode = $xml.DocumentElement
displayNodes $rootNode
Select-Xml -Path $fileName -XPath "/configuration/system.web/httpModules/FileAuthorization/@name" | Select-Object -ExpandProperty Node