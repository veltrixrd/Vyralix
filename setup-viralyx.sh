#!/usr/bin/env bash
# VIRALYX Fase 1 — instalación automática en la raíz del repositorio (Codespaces).
# No borra nada ni hace commit/push. Guarda el resultado de la compilación en build-log.txt.
set -u
ZIP="viralyx-fase1.zip"
TMP="$(mktemp -d)"

echo "==> 1/4 Buscando $ZIP"
[ -f "$ZIP" ] || { echo "ERROR: no encuentro $ZIP en $(pwd). Sube el zip a la raíz del repositorio y vuelve a ejecutar."; exit 1; }
command -v unzip >/dev/null || { echo "==> Instalando unzip"; sudo apt-get update -qq && sudo apt-get install -y -qq unzip; }

echo "==> 2/4 Descomprimiendo y colocando archivos en la raíz"
unzip -q "$ZIP" -d "$TMP" || { echo "ERROR al descomprimir"; exit 1; }
[ -d "$TMP/viralyx" ] || { echo "ERROR: el zip no tiene la carpeta viralyx"; exit 1; }
cp -a "$TMP/viralyx/." . || { echo "ERROR al copiar archivos"; exit 1; }
rm -rf "$TMP"
grep -qx "build-log.txt" .gitignore 2>/dev/null || echo "build-log.txt" >> .gitignore

echo "==> 3/4 Instalando dependencias (puede tardar un par de minutos)"
npm install 2>&1 | tail -n 15
[ "${PIPESTATUS[0]}" -eq 0 ] || { echo "ERROR en npm install. Copia el mensaje de arriba y envíamelo."; exit 1; }

echo "==> 4/4 Compilando (npm run build)"
npm run build 2>&1 | tee build-log.txt
if [ "${PIPESTATUS[0]}" -eq 0 ]; then
  echo; echo "LISTO: el proyecto compila correctamente."
else
  echo; echo "FALLÓ la compilación. Abre build-log.txt, copia el error y envíamelo para corregirlo."
  exit 1
fi
