#!/bin/bash
set -e

echo "Building coc-ruff..."
npm install --legacy-peer-deps
npm run build

echo "Creating package tarball..."
npm pack

echo "Installing to coc extensions directory..."
COC_EXTENSIONS_DIR="$HOME/.config/coc/extensions/node_modules/@yaegassy"
mkdir -p "$COC_EXTENSIONS_DIR"

# Remove old installation if it exists
rm -rf "$COC_EXTENSIONS_DIR/coc-ruff"

# Extract tarball
TARBALL=$(ls yaegassy-coc-ruff-*.tgz | head -1)
tar -xzf "$TARBALL"
mv package "$COC_EXTENSIONS_DIR/coc-ruff"

echo "Updating coc extensions package.json..."
COC_PACKAGE_JSON="$HOME/.config/coc/extensions/package.json"

# Create package.json if it doesn't exist
if [ ! -f "$COC_PACKAGE_JSON" ]; then
  mkdir -p "$(dirname "$COC_PACKAGE_JSON")"
  echo '{"dependencies":{}}' > "$COC_PACKAGE_JSON"
fi

# Add coc-ruff to dependencies if not already present
if ! grep -q "@yaegassy/coc-ruff" "$COC_PACKAGE_JSON"; then
  # Use a simple approach: read, modify, write
  python3 -c "
import json
with open('$COC_PACKAGE_JSON', 'r') as f:
    data = json.load(f)
if 'dependencies' not in data:
    data['dependencies'] = {}
data['dependencies']['@yaegassy/coc-ruff'] = '>=0.8.1'
with open('$COC_PACKAGE_JSON', 'w') as f:
    json.dump(data, f, indent=2)
"
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "Now run the following in Neovim:"
echo "  :CocRestart"
echo ""
echo "All Ruff warnings will now appear as errors."
