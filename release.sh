#!/bin/bash

################################################
# Checkout master
################################################

git checkout master
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
# Commit and push
################################################

assetname=gh-actions-test
updatelink=https://github.com/denismaier/gh-actions-test/releases/download/${version}/${assetname}-${version}.xpi

# Update updates.json
jq ".addons[\"zoteroswisscoveryubbernlocations@ubbe.org\"].updates[0].update_hash = \"sha256:`shasum -a 256 build/${assetname}-${version}.xpi | cut -d' ' -f1`\"" updates.json.tmpl |
jq --arg version "$version" '.addons["zoteroswisscoveryubbernlocations@ubbe.org"].updates[0].version = $version' |
jq --arg updatelink "$updatelink" '.addons["zoteroswisscoveryubbernlocations@ubbe.org"].updates[0].update_link = $updatelink' > updates.json
cp updates.json update.rdf
