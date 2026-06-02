#!/usr/bin/env bash
# One-time setup for ado-testcraft.
# Run this once after installing the plugin. It stores your Azure DevOps
# credentials as persistent environment variables in your shell profile.
#
# Usage: chmod +x setup.sh && ./setup.sh

echo ""
echo "ado-testcraft setup"
echo "==================="
echo "Credentials will be stored in your shell profile."
echo "You only need to run this once."
echo ""

read -r -p "Azure DevOps organization name  (e.g. mycompany): " org
read -r -p "Azure DevOps project name       (e.g. MyProject): " project
read -r -s -p "Your Personal Access Token (PAT) [input hidden]: " pat
echo ""

# Detect shell profile
if [ -n "$ZSH_VERSION" ] || [[ "$SHELL" == */zsh ]]; then
  PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
  PROFILE="$HOME/.bash_profile"
else
  PROFILE="$HOME/.profile"
fi

# Remove any existing ado-testcraft entries
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' '/# ado-testcraft/d; /export ADO_ORG=/d; /export ADO_PROJECT=/d; /export ADO_PAT=/d' "$PROFILE" 2>/dev/null
else
  sed -i '/# ado-testcraft/d; /export ADO_ORG=/d; /export ADO_PROJECT=/d; /export ADO_PAT=/d' "$PROFILE" 2>/dev/null
fi

# Append credentials
{
  echo ""
  echo "# ado-testcraft"
  echo "export ADO_ORG=\"$org\""
  echo "export ADO_PROJECT=\"$project\""
  echo "export ADO_PAT=\"$pat\""
} >> "$PROFILE"

# Clear PAT from memory
pat=""
unset pat

echo ""
echo "Done! Credentials added to $PROFILE:"
echo "  ADO_ORG     = $org"
echo "  ADO_PROJECT = $project"
echo "  ADO_PAT     = [hidden]"
echo ""
echo "Apply now with:  source $PROFILE"
echo "Then restart Claude Code."
echo ""
