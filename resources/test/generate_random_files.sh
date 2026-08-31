#!/usr/bin/env bash
#
# generate_random_files.sh
#
# Erzeugt eine konfigurierbare Anzahl von Textdateien mit zufälligem Inhalt
# (Kodierung: UTF-8). Zeichen pro Zeile und Gesamtzeichenzahl pro Datei
# sind konfigurierbar.
#
# Standard: 10 Dateien, 30000 Zeichen gesamt, 200 Zeichen pro Zeile.

set -euo pipefail

# ==== Standardwerte ====
TOTAL_CHARS=30000
LINE_LENGTH=200
ANZAHL_DATEIEN=100
ZIELVERZEICHNIS="./"
PREFIX="datei"

usage() {
    cat <<EOF
Verwendung: $0 [OPTIONEN]

Erstellt zufällige Textdateien (UTF-8 kodiert) mit konfigurierbarer
Zeilenlänge und Gesamtzeichenzahl pro Datei.

Optionen:
  -c, --chars ANZAHL        Gesamtanzahl Zeichen pro Datei (Standard: 30000)
  -l, --line-length ANZAHL  Zeichen pro Zeile (Standard: 200)
  -n, --num-files ANZAHL    Anzahl zu erstellender Dateien (Standard: 10)
  -d, --dir VERZEICHNIS     Zielverzeichnis (Standard: ./random_files)
  -p, --prefix PREFIX       Dateinamen-Präfix (Standard: datei)
  -h, --help                Diese Hilfe anzeigen

Beispiele:
  $0
  $0 --chars 50000 --line-length 100
  $0 -c 5000 -l 80 -n 3 -d ./output -p testdatei
EOF
}

# ==== Argumente parsen ====
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--chars)
            TOTAL_CHARS="$2"; shift 2 ;;
        -l|--line-length)
            LINE_LENGTH="$2"; shift 2 ;;
        -n|--num-files)
            ANZAHL_DATEIEN="$2"; shift 2 ;;
        -d|--dir)
            ZIELVERZEICHNIS="$2"; shift 2 ;;
        -p|--prefix)
            PREFIX="$2"; shift 2 ;;
        -h|--help)
            usage
            exit 0 ;;
        *)
            echo "Unbekannte Option: $1" >&2
            usage
            exit 1 ;;
    esac
done

# ==== Validierung ====
for wert_name in TOTAL_CHARS LINE_LENGTH ANZAHL_DATEIEN; do
    wert="${!wert_name}"
    if ! [[ "$wert" =~ ^[0-9]+$ ]] || [[ "$wert" -le 0 ]]; then
        echo "Fehler: $wert_name muss eine positive Ganzzahl sein (erhalten: '$wert')." >&2
        exit 1
    fi
done

if ! command -v python3 &>/dev/null; then
    echo "Fehler: python3 wird für die Zeichengenerierung benötigt, ist aber nicht installiert." >&2
    exit 1
fi

mkdir -p "$ZIELVERZEICHNIS"

echo "Erzeuge $ANZAHL_DATEIEN Datei(en) in '$ZIELVERZEICHNIS'"
echo "  Zeichen pro Datei : $TOTAL_CHARS"
echo "  Zeichen pro Zeile : $LINE_LENGTH"
echo

# ==== Erzeugung via Python (garantiert korrekte UTF-8 Kodierung) ====
python3 - "$TOTAL_CHARS" "$LINE_LENGTH" "$ANZAHL_DATEIEN" "$ZIELVERZEICHNIS" "$PREFIX" <<'PYEOF'
import random
import sys
import os

total_chars   = int(sys.argv[1])
line_length   = int(sys.argv[2])
anzahl_dateien = int(sys.argv[3])
zielverzeichnis = sys.argv[4]
prefix = sys.argv[5]

# Zeichenpool: Buchstaben, Zahlen, Satzzeichen, deutsche Umlaute
pool = (
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "0123456789"
    "äöüÄÖÜß"
    " .,;:!?-"
)

breite = len(str(anzahl_dateien))

for i in range(1, anzahl_dateien + 1):
    zeichen = [random.choice(pool) for _ in range(total_chars)]
    zeilen = [
        "".join(zeichen[j:j + line_length])
        for j in range(0, total_chars, line_length)
    ]
    inhalt = "\n".join(zeilen) + "\n"

    dateiname = os.path.join(
        zielverzeichnis, f"{prefix}_{str(i).zfill(breite)}.txt"
    )
    with open(dateiname, "w", encoding="utf-8") as f:
        f.write(inhalt)

    print(f"Erstellt: {dateiname}")
PYEOF

echo
echo "Fertig! $ANZAHL_DATEIEN Datei(en) wurden erfolgreich erstellt."
