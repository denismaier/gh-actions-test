#!/bin/bash

set -eou pipefail

assetname=gh-actions-test

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
jq --arg ver "$version" '.version = $ver' "src/manifest.json" > src/manifest.json

git add install.rdf manifest.json
git commit -m "bump version"

################################################
# Build
################################################

./build.sh $version

################################################
# Update updates.json
################################################

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
gh pr create


################################################
# Create release using the Github CLI after merge
################################################

# gh release create $version build/${assetname}-${version}.xpi -t "${version}"


