#!/bin/bash

################################################
# Get next version number
################################################

current=$(git describe --tags)
echo "Current version: $current"
read -r -p "Enter new version number: " version
echo "Next version set to: $version"

################################################
## Update install.rdf and manifest.json
################################################

#perl -pi -e "s/em:version=\"[^\"]*/em:version=\"$version/;" src/install.rdf
perl -pi -e "s/\"version\": \"[^\"]*\"/\"version\": \"$version\"/" src/manifest.json

################################################
## Make PR using the Github CLI
################################################

git commit -am "bump version"
gh pr create