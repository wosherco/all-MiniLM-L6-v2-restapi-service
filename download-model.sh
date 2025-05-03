#!/bin/bash

# Create directory structure
mkdir -p models/all-MiniLM-L6-v2/1_Pooling

# Base URL for the model
BASE_URL="https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/main"

# List of files to download
FILES=(
  "modules.json"
  "config.json"
  "sentence_bert_config.json"
  "tokenizer_config.json"
  "tokenizer.json"
  "vocab.txt"
  "rust_model.ot"
  "1_Pooling/config.json"
  "model.npz"
)

# Download each file
for file in "${FILES[@]}"; do
  echo "Downloading $file..."
  
  # Create directory structure if needed
  dir=$(dirname "models/all-MiniLM-L6-v2/$file")
  mkdir -p "$dir"
  
  # Download file
  curl -L "$BASE_URL/$file?download=true" -o "models/all-MiniLM-L6-v2/$file"

  # Check if download was successful
  if [ $? -eq 0 ]; then
    echo "Successfully downloaded $file"
  else
    echo "Failed to download $file"
  fi
done

echo "Download complete!"
