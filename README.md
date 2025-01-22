# Crypto Preise
## How to use
Bevor es losgeht, muss der API Key von Coinmarketcap in die Registry eingetragen werden. Am besten nutze dafür die `API Import.reg` Datei. Editiere die vorab und trage dort deinen persönlichen API Key ein. Anschließend importiere die Reg Datei.<br />
Am besten den Pfad der Scripte in den Windows Path Umgebungsvariablen hinzufügen.<br />
Aufruf:
```sh
   <coin> <anzahl optional>
```

Beispiel:
```sh
btc
```
```sh
btc 0.154
```
## coinmarketcap.com
Die aktuellen Preise werden von Coinmarketcap gezogen. Jedes Script hat demendsprechend die API für coinmarketcap.com intergriert.<br />
Sollte man einen neune Coin hinzufügen wollen, muss nur das SAcript `crypto-id` genutzt werden um die ID des Coins auf coinmarketcap.com zu erfahren.<br />
Beispiel:
```sh
crypto-id bcn
```

## Supportete Coins
Bisher werden die folgenden Coins unterstützt:
* bnb
* btc
* cro
* dash
* dashd
* doge
* duco
* edel
* eth
* firo
* ghny
* gmt
* gst
* hnt
* ltc
* monk
* pny
* scc
* shib
* sol
* trump
* xmr
* xp