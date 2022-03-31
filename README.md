# Crypto Preise
## How to use
Am besten den Pfad der Scripte in den Windows Path Umgebungsvariablen hinzufügen.
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
Die aktuellen Preise werden von Coinmarketcap gezogen. Jedes Script hat demendsprechend die API für coinmarketcap.com intergriert.
Sollte man einen neune Coin hinzufügen wollen, muss nur das SAcript `crypto-id` genutzt werden um die ID des Coins auf coinmarketcap.com zu erfahren.
Beispiel:
```sh
crypto-id bcn
```

## Supportete Coins
Bisher werden die folgenden Coins unterstützt:
* btc
* cro
* eth
* firo
* hnt
* ltc
* monk
* pny
* scc
* shib
* xmr
* xp