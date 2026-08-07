# XSLT Pipeline Application

PHP aplikace pro sekvenční transformaci XML dokumentů pomocí XSLT 3.0 a Saxon-HE 12.9.

Aplikace byla vytvořena s pomocí [Copilotu](https://copilot.microsoft.com).

## Struktura projektu

```text
.
├── api.php                      # Hlavní API endpoint (GET/POST)
├── openapi.json                 # OpenAPI 3.1.0 schéma
├── src/
│   └── transformer.php          # Třída pro sekvenční XSLT transformace
├── input/                       # Vstupní XML soubory (pojmenovány podle lemma-id)
├── transforms/
│   ├── <target>/                # Složka se sadou transformací
│   │   ├── 001-*.xsl
│   │   ├── 002-*.xsl
│   │   └── ...
├── expected/
│   ├── <target>/                # Očekávané výsledky pro každý target
│   │   ├── <lemma-id>.xml
│   │   └── ...
├── output/                      # Generované transformované soubory
│   └── <target>/
│       ├── <lemma-id>.xml
│       └── ...
├── test/
│   ├── run-tests.http           # Tests in REST Client format
│   ├── run-tests.php            # PHP test runner
│   ├── run-tests.ps1            # PowerShell test runner
│   ├── run-tests.bat            # Batch test runner
│   └── test-report.json         # Výstupní report
├── lib/                         # Externí knihovny (Saxon-HE JAR)
└── README.md                    # Tato dokumentace
```

## Požadavky

- PHP 7.4+
- Java Runtime Environment (JRE) 11+ (pro Saxon-HE 12.9)
- Saxon-HE 12.9 JAR soubor

### Instalace Saxon-HE

1. Stáhněte Saxon-HE 12.9 z: <https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE12-9/SaxonHE12-9J.zip>
2. Umístěte soubor `saxon-he-12.9.jar` a jeho podsložku `lib` do adresáře `lib/`

## Použití

### Spuštění webového serveru

```bash
php -S localhost:8000 api.php
```

### GET požadavek

```bash
curl "http://localhost:8000/transform?lemma-id=400&target=lemmas-xml"
```

### POST požadavek

```bash
curl -X POST http://localhost:8000/transform \
  -H "Content-Type: application/json" \
  -d '{"lemma-id":"400","target":"lemmas-xml"}'
```

## Testování

### PHP test runner

```bash
php test/run-tests.php
```

Tento script:

1. Načte všechny vstupní XML soubory z adresáře `input/`
2. Pro každý dostupný target v `transforms/` spustí transformaci
3. Porovná výstup s očekávanými soubory v `expected/<target>/`
4. Vygeneruje report do `test/test-report.json`

### PowerShell test runner (Windows)

```powershell
.\test\run-tests.ps1
```

### Batch test runner (Windows CMD)

```cmd
test\run-tests.bat
```

## Příprava testovacích dat

### 1. Vstupní XML

Umístěte XML soubory do `input/` adresáře s názvem odpovídajícím `lemma-id`:

```text
input/
├── 1.xml
├── 400.xml
└── 31622.xml
```

### 2. XSLT transformace

Vytvořte adresáře se sadami transformací:

```text
transforms/
├── headwords-xml/
│   ├── 001-variants.xsl
│   ├── 002-list.xsl
│   └── 003-expand-values.xsl
├── lemmas-xml/
│   ├── 001-xml.xsl
└── teilex0-0/
    └── 001-to-teilex0.xsl
```

Soubory XSLT **musejí** být pojmenované sekvenčně s prefixem `NNN-` (000-999).
Aplikují se v abecedním pořadí, tedy podle tohoto prefixu.

### 3. Očekávané výsledky

Umístěte očekávané výsledky transformací:

```text
expected/
├── headwords/
│   ├── 1.xml
│   ├── 400.xml
│   └── 31622.xml
├── headwords-xml/
│   ├── 1.xml
│   ├── 400.xml
│   └── 31622.xml
└── teilex0-xml/
    ├── 1.xml
    ├── 400.xml
    └── 31622.xml
```

## OpenAPI schéma

OpenAPI dokumentace je k dispozici v souboru `openapi.json`.

### GET /transform

Parametry (query string):

- `lemma-id` (povinný): Identifikátor vstupního souboru, tj. název souboru bez přípony
- `target` (povinný): Sada transformací, tj. označení složky, která sadu transformací obsahuje. Označení v názvu obsahuje za pomlčkou typ výstupu (např. `xml` nebo `tsv`), na základě kterého se generuje odpovídají `Content-Type` v hlavičce odpovědi REST API.

Odpovědi: 200 (XML), 400 (chyba validace), 404 (soubor nenalezen), 500 (chyba serveru)

### POST /transform

Tělo požadavku (JSON):

```json
{
  "lemma-id": "1",
  "target": "basic"
}
```

Odpovědi: 200 (XML), 400 (chyba validace), 404 (soubor nenalezen), 500 (chyba serveru)

## Třída Transformer

Hlavní třída `Transformer` v `src/transformer.php` poskytuje:

```php
$transformer = new Transformer($saxonJarPath);
$result = $transformer->transform($inputXmlPath, $transformDirPath, $saveOutput);
```

### Parametry

- `$inputXmlPath`: Cesta k vstupnímu XML souboru
- `$transformDirPath`: Cesta k adresáři obsahujícímu XSLT soubory
- `$saveOutput`: Zda uložit výstup do `output/` adresáře (výchozí: false)

### Návraty

Metoda `transform()` vrací obsah transformovaného XML jako string.

### Výjimky

Metoda vyvolá `Exception` v případě:

- Chybějícího vstupního souboru
- Chybějícího adresáře transformací
- Chyby Saxon-HE během transformace
- Chyby při vytváření výstupního souboru

## Test report JSON

Po spuštění testů je vygenerován soubor `test/test-report.json`:

```json
{
  "timestamp": "2024-04-24T10:30:00+00:00",
  "summary": {
    "passed": 3,
    "failed": 0,
    "total": 3
  },
  "results": [
    {
      "target": "basic",
      "lemma-id": "400",
      "input": "...",
      "output": "...",
      "expected": "...",
      "status": "PASSED",
      "error": null,
      "diff": false
    }
  ]
}
```

## Poznámky

### Dočasné soubory

Při sekvenční aplikaci transformací aplikace vytváří dočasné XML soubory. Ty se automaticky odstraňují po dokončení transformace.

### Bezpečnost

API validuje vstupní parametry `lemma-id` a `target` aby se zabránilo directory traversal útokům. Povoleny jsou pouze alfanumerické znaky, pomlčka a podtržítko.

### Kódování

Všechny soubory používají kódování UTF-8.

## Řešení problémů

### Java nenalezena

Pokud dostanete chybu "java not found", ujistěte se, že:

1. Java je nainstalována a je v PATH
2. Verze Javy je 11 nebo vyšší: `java -version`

### Saxon-HE JAR nenalezen

Zkontrolujte, že soubor `saxon-he-12.9.jar` je umístěn v adresáři `lib/`.

### Transformace selhává

Zkontrolujte:

1. Formát vstupního XML
2. Syntaxi XSLT souboru
3. Kompatibilitu s XSLT 3.0 a Saxon-HE 12.9

## Licence

Projekt je poskytován pod licencí [GNU GENERAL PUBLIC LICENSE, Version 3](LICENSE).
