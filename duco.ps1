param (
	[string]$crypto=""
	)

Write-Host -ForegroundColor Red Duco
Write-Host 417 Ducos sind ca. ein US Cent.

if($crypto) {
	$temp = (0.01/417) * $crypto
	Write-Host "$"$temp
}
