param (
    [string]$fileName = "C:\LCD\GIT\self\Resume\powershell\web.Config"
)

function Print-Attributes ($node) {
    $node_attributes = $node.attributes
    foreach($attrbute in $node_attributes) {
        Write-Output $attribute.Name
        Write-Output $attribute.value
    }
}

function Traverse-Nodes ($nodes) {
    Print-Attributes $nodes
    foreach($node in $nodes) {
        $node_name = $node.Name
        Write-Output $node_name
        Traverse-Nodes($node.ChildNodes)
    }
}

$nodeNames = [System.Collections.ArrayList]::new()
[xml]$xml = Get-Content $fileName
$xml | Get-Member
$childNodes = $xml.ChildNodes
Traverse-Nodes ($childNodes)