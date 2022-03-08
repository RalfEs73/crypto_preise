$headers = @{
    'X-CMC_PRO_API_KEY'='02372bda-5f7d-444b-891b-fee24172e440'
    Content='application/json'
}

$temp = Read-Host "Welche Crypto"
$response = Invoke-RestMethod -Method Get -Uri "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map?symbol=$temp" -Headers $headers
$data = $response | ConvertTo-Json

$max = $response.data.length


for ($i=0; $i -lt $max; $i++)
	{
	$response.data[$i].name
	$response.data[$i].id
    
	}
