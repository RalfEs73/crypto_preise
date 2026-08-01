param (
	[string]$crypto="btc"
	)

$ApiKey = Get-Content "$PSScriptRoot/Token.txt"

$headers = @{
    'X-CMC_PRO_API_KEY'="$api"
    Content='application/json'
}

$response = Invoke-RestMethod -Method Get -Uri "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map?symbol=$crypto" -Headers $headers
$data = $response | ConvertTo-Json -Depth 9

$max = $response.data.length


for ($i=0; $i -lt $max; $i++)
	{
	Write-Host -ForegroundColor Red $response.data[$i].name
	Write-Host $response.data[$i].id
	}
