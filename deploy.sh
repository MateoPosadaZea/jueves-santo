#!/usr/bin/env bash
# deploy.sh — publica jueves-santo en GitHub Pages en un solo paso.
# Uso:  ./deploy.sh "mensaje del commit"
set -euo pipefail

cd "$(dirname "$0")"

MSG="$*"
if [ -z "$MSG" ]; then
  echo "Uso: ./deploy.sh \"mensaje del commit\"" >&2
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [ -z "$BRANCH" ]; then
  echo "No estas en una rama (HEAD suelto). Corre: git checkout main" >&2
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "No hay cambios para commitear. Nada que publicar."
  exit 0
fi

echo "--- Se van a publicar estos cambios en '$BRANCH' ---"
git diff --cached --stat
echo "----------------------------------------------------"

git commit -m "$MSG"

# Push con reintentos (2s, 4s, 8s, 16s) por si la red falla.
delay=2
for intento in 1 2 3 4 5; do
  if git push -u origin "$BRANCH"; then
    echo
    echo "Listo. Publicado en '$BRANCH'."
    if [ "$BRANCH" = "main" ]; then
      echo "GitHub Pages republica solo en ~1-2 min:"
      echo "  https://mateoposadazea.github.io/jueves-santo/"
      echo "Si no ves el cambio, recarga con Cmd+Shift+R (cache del navegador)."
    else
      echo "Ojo: estas en la rama '$BRANCH', no en 'main'."
      echo "GitHub Pages publica desde 'main', asi que el sitio NO cambia todavia."
    fi
    exit 0
  fi
  if [ "$intento" -lt 5 ]; then
    echo "Push fallo. Reintentando en ${delay}s... ($intento/4)" >&2
    sleep "$delay"
    delay=$((delay * 2))
  fi
done

echo "El push fallo despues de 5 intentos. El commit quedo hecho localmente;" >&2
echo "revisa tu conexion o tus credenciales y corre: git push -u origin $BRANCH" >&2
exit 1
