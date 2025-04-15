#!/bin/bash

set -e

VERSION_TAG=$1

if [ -z "$VERSION_TAG" ]; then
  echo "❌ Укажи версию, например: ./release_to_public.sh v1.3.0"
  exit 1
fi

echo "📦 Создаем релиз $VERSION_TAG из ветки main → release"

git checkout main
git pull origin main

git checkout release || git checkout -b release
git reset --hard origin/release || echo "🆕 Создаем новую ветку release"

# Сквошим изменения из main
git merge --squash main
git commit -m "Release $VERSION_TAG"
git tag "$VERSION_TAG"

# Пушим только ветку и тег в публичный репо
echo "🚀 Публикуем в public..."
git push public release --force
git push public "$VERSION_TAG"

echo "✅ Релиз $VERSION_TAG опубликован в публичном репозитории."