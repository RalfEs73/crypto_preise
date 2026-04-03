[CmdletBinding(DefaultParameterSetName = 'ById')]
param(
    # ✅ Erste Zahl nach Scriptstart = Amount
    [Parameter(Position=0)]
    [ValidateRange(0.00000001, 1e18)]
    [double]$Amount = 1,

    # CoinMarketCap ID (Default = SOL)
    [Parameter(ParameterSetName='ById')]
    [int]$CryptoId = 20396,

    # Alternative Auswahl per Symbol
    [Parameter(ParameterSetName='BySymbol')]
    [ValidatePattern('^[A-Za-z0-9]{2,10}$')]
    [string]$Symbol,

    [ValidatePattern('^[A-Z]{3,5}$')]
    [string]$Convert = "USD",

    [string]$RegPath = "HKCU:\Software\Crypto Preise",
    [string]$RegValue = "API_KEY",

    [switch]$ShowUnitAndTotal,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-CmcApiKey {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Value
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Registry-Pfad nicht gefunden: $Path"
    }

    $reg = Get-ItemProperty -LiteralPath $Path -ErrorAction Stop

    if (-not ($reg.PSObject.Properties.Name -contains $Value)) {
        throw "Registry-Wert '$Value' nicht gefunden unter: $Path"
    }

    $apiKey = [string]$reg.$Value
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "API-Key ist leer in Registry: $Path\$Value"
    }

    return $apiKey.Trim()
}

function Resolve-CmcIdFromSymbol {
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,
        [Parameter(Mandatory)]
        [string]$Symbol
    )

    $headers = @{
        'X-CMC_PRO_API_KEY' = $ApiKey
        'Accept'           = 'application/json'
        'User-Agent'       = 'PS-CryptoPrice/1.1'
    }

    $sym = [uri]::EscapeDataString($Symbol.ToUpperInvariant())
    $uri = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map?symbol=$sym"

    $resp = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -TimeoutSec 20

    if (-not $resp.data -or $resp.data.Count -lt 1) {
        throw "Kein Coin gefunden für Symbol '$Symbol'."
    }

    return [int]$resp.data[0].id
}

function Get-CmcConversion {
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,
        [Parameter(Mandatory)]
        [int]$CryptoId,
        [Parameter(Mandatory)]
        [double]$Amount,
        [Parameter(Mandatory)]
        [string]$Convert
    )

    $headers = @{
        'X-CMC_PRO_API_KEY' = $ApiKey
        'Accept'           = 'application/json'
        'User-Agent'       = 'PS-CryptoPrice/1.1'
    }

    $convertUpper = $Convert.ToUpperInvariant()

    $uri = "https://pro-api.coinmarketcap.com/v1/tools/price-conversion?id=$CryptoId&amount=$Amount&convert=$convertUpper"
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -TimeoutSec 20

    return $response
}

try {
    # TLS Fix (PS 5.1)
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    $apiKey = Get-CmcApiKey -Path $RegPath -Value $RegValue

    if ($PSCmdlet.ParameterSetName -eq 'BySymbol') {
        $CryptoId = Resolve-CmcIdFromSymbol -ApiKey $apiKey -Symbol $Symbol
    }

    $Convert = $Convert.ToUpperInvariant()

    $response = Get-CmcConversion -ApiKey $apiKey -CryptoId $CryptoId -Amount $Amount -Convert $Convert

    # --------------------------
    # ROBUSTES PARSING (Fix für SOL/Amount)
    # --------------------------
    $dataObj = $response.data

    # Falls data ein Array ist, erstes Element verwenden (manchmal liefert CMC arrays)
    if ($dataObj -is [System.Collections.IEnumerable] -and -not ($dataObj -is [string])) {
        $dataObj = @($dataObj)[0]
    }

    $name = $dataObj.name
    if (-not $name) { $name = "CryptoId $CryptoId" }

    $quoteObj = $null
    if ($dataObj.quote) {
        $quoteObj = $dataObj.quote.$Convert
    }

    if (-not $quoteObj -or -not $quoteObj.price) {
        $raw = $response | ConvertTo-Json -Depth 12
        throw "Preis nicht gefunden unter response.data.quote.$Convert.price. Raw (gekürzt): $($raw.Substring(0, [Math]::Min(900, $raw.Length)))"
    }

    # price ist der Gesamtwert für Amount (z.B. 5 SOL -> USD)
    $totalPrice = [double]$quoteObj.price

    # Formatierung Währungssymbol (einfach)
    $label = if ($Convert -eq "EUR") { "€" } elseif ($Convert -eq "USD") { "$" } else { "$Convert " }

    if ($AsJson) {
        $unit = $totalPrice / $Amount

        [pscustomobject]@{
            name           = $name
            id             = $CryptoId
            symbol         = ($Symbol ?? $null)
            amount         = $Amount
            convert        = $Convert
            unit_price     = [Math]::Round($unit, 8)
            total_price    = [Math]::Round($totalPrice, 8)
            fetched        = (Get-Date).ToString("o")
        } | ConvertTo-Json -Depth 5
        return
    }

    Write-Host -ForegroundColor Red $name

    if ($ShowUnitAndTotal -and $Amount -ne 1) {
        $unitPrice = $totalPrice / $Amount
        Write-Host ("1 Coin:  {0}{1:N4}" -f $label, $unitPrice)
        Write-Host ("{0} Coin(s): {1}{2:N4}" -f $Amount, $label, $totalPrice)
    }
    else {
        # Standard: zeigt den (Gesamt-)Preis der angegebenen Amount
        Write-Host ("{0}{1:N4}" -f $label, $totalPrice)
    }
}
catch {
    Write-Error ("Fehler: {0}" -f $_.Exception.Message)

    # Wenn möglich HTTP Status ausgeben
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
        Write-Error ("HTTP Status: {0}" -f $_.Exception.Response.StatusCode.value__)
    }
    exit 1
}