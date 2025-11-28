#!/usr/bin/env bash

REPO_USER="overseeric"
REPO_NAME="SIGQR"
BRANCH="main"

# Carpeta donde se guardarán los QR
OUTPUT_DIR="qrs"
mkdir -p "$OUTPUT_DIR"

# 1. Recorrer todos los MP3
find . -type f -name "*.MP3" | while read -r file; do
  # Quitar el './' del inicio
  rel_path="${file#./}"

  # 2. Construir la URL RAW de githack
  raw_url="https://rawcdn.githack.com/${REPO_USER}/${REPO_NAME}/${BRANCH}/${rel_path}"

  # 3. Codificar la URL para que vaya bien en el parámetro data
  encoded_raw_url=$(python3 - <<EOF
import urllib.parse
print(urllib.parse.quote("$raw_url", safe=''))
EOF
)

  # 4. URL del servicio de QR
  qr_api_url="https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encoded_raw_url}"

  # 5. Mantener estructura de carpetas
  rel_dir=$(dirname "$rel_path")
  if [ "$rel_dir" != "." ]; then
    out_dir="${OUTPUT_DIR}/${rel_dir}"
    mkdir -p "$out_dir"
  else
    out_dir="$OUTPUT_DIR"
  fi

  # 6. Nombre del archivo PNG
  base_name="$(basename "$rel_path" .MP3)"
  output_file="${out_dir}/${base_name}.png"

  echo "Generando QR para: $rel_path"
  echo " -> $output_file"

  # 7. Descargar la imagen del QR
  curl -s "$qr_api_url" -o "$output_file"
done

echo "✅ Listo. QRs generados en la carpeta: $OUTPUT_DIR"
