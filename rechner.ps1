param (
	[string]$einkauf="",
	[string]$verkauf=""
	)

$RegPath="HKCU:\Software\Crypto Preise"
$reg=Get-ItemProperty $RegPath
$api = $reg.API_KEY

$headers = @{
    'X-CMC_PRO_API_KEY'="$api"
    Content='application/json'
}

$crypto_id = 18069
$response = Invoke-RestMethod -Method Get -Uri "https://pro-api.coinmarketcap.com/v1/tools/price-conversion?id=$crypto_id&amount=1&convert=USD" -Headers $headers
$data = $response | ConvertTo-Json -Depth 9

$gebuegren = 6

if($einkauf) {
	$gebuehren = ( $verkauf / 100 ) * 6
	$gewinn = $verkauf - $einkauf - $gebuehren
	$gewinn_dollar = $response.data[0].quote[0].USD[0].price * $gewinn
	
	Write-Host "Einkauf: $einkauf GMT"
	Write-Host "Verkauf $verkauf GMT"
	Write-Host "Gebühren: $gebuehren GMT"
	Write-Host
	Write-Host -ForegroundColor Red "Gewinn: $gewinn GMT"
	Write-Host -ForegroundColor Red "Gewinn:"$"$gewinn_dollar"
	
	Write-Host $temp
	}
	else
	{
	Write-Host -ForegroundColor Red "<Einkaufspreis> <Verkaufspreis>"
	}