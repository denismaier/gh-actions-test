#!/bin/bash

version="$1"
if [ -z "$version" ]; then
	read -p "Enter new version number: " version
fi

echo "Building version ${version}"

assetname=gh-actions-test

# Create build folder
rm -rf build
mkdir build

# Create build zip
cd src
zip -r ../build/${assetname}-${version}.xpi *