#!/bin/bash

# TAD Framework Installer - Redirects to unified tad.sh
# For backward compatibility with existing install links

echo "Redirecting to unified TAD installer..."
echo ""

# Download and run tad.sh
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
