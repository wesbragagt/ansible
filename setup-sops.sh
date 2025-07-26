#!/bin/bash
# Script to set up SOPS with age encryption

echo "=== SOPS Setup Script ==="
echo ""

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "Error: age is not installed. Please install it first."
    echo "You can install it with: nix-shell -p age"
    exit 1
fi

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "Error: sops is not installed. Please install it first."
    echo "You can install it with: nix-shell -p sops"
    exit 1
fi

# Create age key directory
mkdir -p ~/.config/sops/age

# Check if age key already exists
if [ -f ~/.config/sops/age/keys.txt ]; then
    echo "Age key already exists at ~/.config/sops/age/keys.txt"
    echo "Extracting public key..."
    PUBLIC_KEY=$(grep -o "public key: age.*" ~/.config/sops/age/keys.txt | cut -d' ' -f3)
else
    echo "Generating new age key..."
    age-keygen -o ~/.config/sops/age/keys.txt
    echo "Age key generated at ~/.config/sops/age/keys.txt"
    PUBLIC_KEY=$(grep -o "public key: age.*" ~/.config/sops/age/keys.txt | cut -d' ' -f3)
fi

echo ""
echo "Your age public key is: $PUBLIC_KEY"
echo ""

# Update .sops.yaml with the actual public key
echo "Updating .sops.yaml with your public key..."
sed -i.bak "s/age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/$PUBLIC_KEY/g" .sops.yaml

echo ""
echo "Now encrypting the test secret..."
echo ""

# Encrypt the test secret
if sops -e -i secrets/test-secret.yaml; then
    echo "✅ Test secret encrypted successfully!"
    echo ""
    echo "The file secrets/test-secret.yaml is now encrypted."
    echo "You can decrypt it with: sops -d secrets/test-secret.yaml"
else
    echo "❌ Failed to encrypt test secret"
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Run 'nix develop' or 'home-manager switch --flake .' to activate the configuration"
echo "2. Check that ~/.ssh/test-secret.txt contains the decrypted secret"