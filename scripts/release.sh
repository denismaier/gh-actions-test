#!/bin/bash

set -eou pipefail

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

################################################
# Build
################################################

./build.sh $baseName $version

################################################
# Update updates.json
################################################

updatelink=https://github.com/${repoOwner}/${repoName}/releases/download/${version}/${baseName}-${version}.xpi
update_hash="sha256:$(shasum -a 256 build/${baseName}-${version}.xpi | cut -d' ' -f1)"

# Update updates.json

jq --arg version "$version" \
    --arg updatelink "$updatelink" \
    --arg updatehash "$update_hash" \
    --arg pluginID "$pluginID" \
   '.addons[$pluginID].updates[0].version = $version |
    .addons[$pluginID].updates[0].update_link = $updatelink |
    .addons[$pluginID].updates[0].update_hash = $updatehash' \
   updates.json.tmpl > updates.json

cp updates.json update.rdf

################################################
# Commit changes
################################################

# Check if updates.json or update.rdf have changes
if ! git diff-index --quiet HEAD updates.json update.rdf; then
    echo "Changes detected in updates.json or update.rdf. Proceeding with commit."
    git add updates.json update.rdf
    git commit -m "Update update.json"
else
    echo "No changes detected in updates.json or update.rdf. Skipping commit."
fi

################################################
# Push and create PR using the Github CLI
################################################

git push

# Check if a pull request already exists for the branch
existing_pr=$(gh pr list --search "head:${repoOwner}:${branch}" --json number --jq '.[] | .number')

if [ -z "$existing_pr" ]; then
  gh pr create
else
  echo "A pull request already exists for branch ${branch}. Skipping pull request creation."
fi