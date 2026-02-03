#!/usr/bin/env bash
set -euo pipefail

MANIFEST="${MANIFEST:-../ops/data/datasets_manifest.tsv}"
ZIP_DIR="${ZIP_DIR:-../tmp/data/zips}"
OUT_DIR="${OUT_DIR:-../tmp/data/extracted}"
META_DIR="${META_DIR:-../tmp/data/meta}"

mkdir -p "$ZIP_DIR" "$OUT_DIR" "$META_DIR"

download() {
  local url="$1" out="$2"
  curl -fL --retry 3 --retry-delay 1 -o "$out" "$url"
}

sha256_file() {
  sha256sum "$1" | awk '{print $1}'
}

verify_sha256() {
  local file="$1" expected="$2"
  local got
  got="$(sha256_file "$file")"
  [[ "$got" == "$expected" ]]
}

extract_zip() {
  local zip="$1" dest="$2"
  rm -rf "$dest"
  mkdir -p "$dest"
  unzip -q "$zip" -d "$dest"
}

sanity_check_csvs() {
  local dir="$1"
  # Au moins un CSV non vide
  local csv
  csv="$(find "$dir" -type f -name '*.csv' -size +0c | head -n 1 || true)"
  [[ -n "$csv" ]]
}

while IFS=$'\t' read -r id url sha; do
  [[ -z "${id:-}" || "$id" =~ ^# ]] && continue

  zip_path="$ZIP_DIR/${id}.zip"
  extract_path="$OUT_DIR/${id}"
  hash_file="$META_DIR/${id}.sha256"

  echo "==> $id"

  if [[ "$sha" != "-" && -n "$sha" ]]; then
    # Dataset figé : on peut faire un cache strict par checksum.
    if [[ -f "$zip_path" ]]; then
      echo "    zip already present: $zip_path"
      echo "    verifying sha256..."
      if verify_sha256 "$zip_path" "$sha"; then
        echo "    checksum ok, skipping download"
      else
        echo "    checksum mismatch, re-downloading..."
        download "$url" "$zip_path"

        echo "    verifying sha256 (after download)..."
        if ! verify_sha256 "$zip_path" "$sha"; then
          echo "ERROR: checksum mismatch for $id" >&2
          echo "       file: $zip_path" >&2
          echo "       got : $(sha256_file "$zip_path")" >&2
          echo "       want: $sha" >&2
          exit 1
        fi
      fi
    else
      download "$url" "$zip_path"

      echo "    verifying sha256..."
      if ! verify_sha256 "$zip_path" "$sha"; then
        echo "ERROR: checksum mismatch for $id" >&2
        echo "       file: $zip_path" >&2
        echo "       got : $(sha256_file "$zip_path")" >&2
        echo "       want: $sha" >&2
        exit 1
      fi
    fi

    # Optionnel : on peut aussi éviter de ré-extraire si rien n’a changé
    # en stockant le hash du zip même pour les datasets figés.
    new_hash="$(sha256_file "$zip_path")"
    old_hash=""
    [[ -f "$hash_file" ]] && old_hash="$(cat "$hash_file")"
    if [[ "$new_hash" == "$old_hash" ]]; then
      echo "    unchanged (sha256=$new_hash), skipping extraction"
      continue
    fi
    echo "$new_hash" >"$hash_file"

  else
    # Dataset mouvant : meilleure stratégie = comparer au hash précédent.
    # Si zip existant et hash identique -> pas besoin de télécharger ni d'extraire.
    if [[ -f "$zip_path" ]]; then
      new_hash="$(sha256_file "$zip_path")"
      old_hash=""
      [[ -f "$hash_file" ]] && old_hash="$(cat "$hash_file")"

      if [[ -n "$old_hash" && "$new_hash" == "$old_hash" ]]; then
        echo "    zip unchanged (sha256=$new_hash), skipping download & extraction"
        continue
      fi

      echo "    zip present but changed/unknown (sha256=$new_hash), downloading latest..."
      download "$url" "$zip_path"
    else
      download "$url" "$zip_path"
    fi

    new_hash="$(sha256_file "$zip_path")"
    old_hash=""
    [[ -f "$hash_file" ]] && old_hash="$(cat "$hash_file")"

    if [[ "$new_hash" == "$old_hash" ]]; then
      echo "    unchanged (sha256=$new_hash), skipping extraction"
      continue
    fi

    echo "    updated (sha256=$new_hash), extracting and updating hash"
    echo "$new_hash" >"$hash_file"
  fi

  extract_zip "$zip_path" "$extract_path"

  echo "    sanity check..."
  if ! sanity_check_csvs "$extract_path"; then
    echo "ERROR: no non-empty CSV found after extraction for $id" >&2
    exit 1
  fi

  echo "    ok: extracted to $extract_path"
done <"$MANIFEST"
