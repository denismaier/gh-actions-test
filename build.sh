#!/bin/bash

# Get the current date and time in the format "YYYYMMDDHHMM"
timestamp=$(date +"%Y%m%d%H%M")

# Get the base name and version from command-line arguments
baseName=${1:-"plugin"}
version=${2:-$timestamp}

echo "Building ${baseName}-${version}"

# Create build folder
rm -rf build
mkdir build

# Create build zip
cd src
zip -r ../build/${baseName}-${version}.xpi *