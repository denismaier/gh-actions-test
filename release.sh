#!/bin/bash

set -eou pipefail

baseName=gh-actions-test
repoOwner=denismaier
repoName=gh-actions-test

################################################
# Get next version number
################################################

current=$(git describe --tags)
echo "Last version: $current"
read -r -p "Enter new version number (without v): " version
echo "Next version set to: $version"

################################################
## Update install.rdf and manifest.json
################################################

#perl -pi -e "s/em:version=\"[^\"]*/em:version=\"$version/;" src/install.rdf
jq --arg ver "$version" '.version = $ver' "src/manifest.json" > temp.json && mv temp.json src/manifest.json

git add src/manifest.json #src/install.rdf
git commit -m "bump version"

################################################
# Build
################################################

./build.sh $baseName $version

################################################
# Update updates.json
################################################

updatelink=https://github.com/${repoOwner}/${repoName}/releases/download/${version}/${baseName}-${version}.xpi

# Update updates.json
jq ".addons[\"zoteroswisscoveryubbernlocations@ubbe.org\"].updates[0].update_hash = \"sha256:`shasum -a 256 build/${baseName}-${version}.xpi | cut -d' ' -f1`\"" updates.json.tmpl |
jq --arg version "$version" '.addons["zoteroswisscoveryubbernlocations@ubbe.org"].updates[0].version = $version' |
jq --arg updatelink "$updatelink" '.addons["zoteroswisscoveryubbernlocations@ubbe.org"].updates[0].update_link = $updatelink' > updates.json
cp updates.json update.rdf

################################################
# Commit changes
################################################

git add updates.json update.rdf
git commit -m "Update update.json"

################################################
# Push and create PR using the Github CLI
################################################q
git push
gh pr create
