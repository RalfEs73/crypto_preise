param (
	[string]$crypto=""
	)
	
$RegPath="HKCU:\Software\Crypto Preise"
$reg=Get-ItemProperty $RegPath
$api = $reg.API_KEY

$headers = @{
    'X-CMC_PRO_API_KEY'="$api"
    Content='application/json'
}

$crypto_id = 74
$response = Invoke-RestMethod -Method Get -Uri "https://pro-api.coinmarketcap.com/v1/tools/price-conversion?id=$crypto_id&amount=1&convert=USD" -Headers $headers
$data = $response | ConvertTo-Json

Write-Host -ForegroundColor Red $response.data[0].name
Write-Host "$"$response.data[0].quote[0].USD[0].price

if($crypto) {
	$temp = $response.data[0].quote[0].USD[0].price * $crypto
	Write-Host "$"$temp
}
