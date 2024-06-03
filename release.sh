#!/bin/bash

assetname=gh-actions-test

################################################
# Checkout master
################################################

git checkout main # or master
git pull

################################################
# Get version number from manifest json
################################################

version=$(jq -r '.version' "src/manifest.json")

################################################
# Build
################################################

./build.sh $version

################################################
# Create release using the Github CLI
################################################

gh release create $version build/${assetname}-${version}.xpi -t "${version}" --generate-notes

################################################
# Update updates.json
################################################

git branch publish-${version}
git checkout publish-${version}

updatelink=https://github.com/denismaier/gh-actions-test/releases/download/${version}/${assetname}-${version}.xpi

# Update updates.json
jq ".addons[\"zoteroswisscoveryubbernlocations@ubbe.org\"].updates[0].update_hash = \"sha256:`shasum -a 256 build/${assetname}-${version}.xpi | cut -d' ' -f1`\"" updates.json.tmpl |
jq --arg version "$version" '.addons["zoteroswisscoveryubbernlocations@ubbe.org"].updates[0].version = $version' |
jq --arg updatelink "$updatelink" '.addons["zoteroswisscoveryubbernlocations@ubbe.org"].updates[0].update_link = $updatelink' > updates.json
cp updates.json update.rdf

################################################
# Commit changes
################################################

git add updates.json update.rdf
git commit -m "Update update.json"

################################################
# Create PR using the Github CLI
################################################q
gh pr create --title "Update update.json for $version" --body "Adjust version info for $version"
