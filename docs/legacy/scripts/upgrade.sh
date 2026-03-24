#!/bin/bash

# TAD Framework Upgrader - Redirects to unified tad.sh
# For backward compatibility with existing upgrade links

echo "Redirecting to unified TAD installer..."
echo ""

# Download and run tad.sh
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
