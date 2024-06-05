#!/bin/bash

baseName=gh-actions-test
repoOwner=denismaier
repoName=gh-actions-test
pluginID=zoteroswisscoveryubbernlocations@ubbe.org

################################################
# Get next version number
################################################

# Get the last tag
last_tag=$(git describe --tags --abbrev=0)
echo "Last tag: $last_tag"

# Get the current version number from manifest.json
current=$(jq -r '.version' src/manifest.json)
echo "Current version in manifest.json: $current"

# Ask for the new version number
read -r -p "Enter new version number (without v), or press enter to use current version: " version
if [[ -z $version ]]; then
    echo "Version number is empty. Using current version."
    version=$current
else
    echo "Next version set to: $version"
fi

################################################
## Update install.rdf and manifest.json
################################################

#perl -pi -e "s/em:version=\"[^\"]*/em:version=\"$version/;" src/install.rdf
jq --arg ver "$version" '.version = $ver' "src/manifest.json" > temp.json && mv temp.json src/manifest.json

git add src/manifest.json #src/install.rdf
git diff-index --quiet HEAD -- src/manifest.json || git commit -m 'bump version'