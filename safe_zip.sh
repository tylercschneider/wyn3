#!/bin/bash

# Name of the output zip file
ZIP_NAME="wyn2_clean.zip"

# Path to your Rails project root (edit if needed)
PROJECT_DIR="."

# Create a safe, clean zip excluding unwanted files
zip -r "$ZIP_NAME" "$PROJECT_DIR" \
  -x "*.DS_Store" \
  -x "*.log" \
  -x "log/*" \
  -x "tmp/*" \
  -x "node_modules/*" \
  -x "storage/*" \
  -x "public/packs/*" \
  -x "public/assets/*" \
  -x ".git/*" \
  -x ".gitignore" \
  -x ".env*" \
  -x "config/credentials/*" \
  -x "*.sqlite3" \
  -x "*.swp" \
  -x "*~" \
  -x "__MACOSX" \
  -x "*.zip"

echo "✅ Created $ZIP_NAME (excluding sensitive/big files)"
