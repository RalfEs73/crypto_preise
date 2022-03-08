param (
	[string]$crypto=""
	)
	
$headers = @{
    'X-CMC_PRO_API_KEY'='02372bda-5f7d-444b-891b-fee24172e440'
    Content='application/json'
}

$crypto_id = 3986
$response = Invoke-RestMethod -Method Get -Uri "https://pro-api.coinmarketcap.com/v1/tools/price-conversion?id=$crypto_id&amount=1&convert=USD" -Headers $headers
$data = $response | ConvertTo-Json
# $response.data[0].name
# $response.data[0].quote[0].USD[0].price

Write-Host -ForegroundColor Red $response.data[0].name
Write-Host "$"$response.data[0].quote[0].USD[0].price

if($crypto) {
	$temp = $response.data[0].quote[0].USD[0].price * $crypto
	Write-Host "$"$temp
}
