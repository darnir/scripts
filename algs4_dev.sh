#!/bin/bash

SPWD=$(pwd)

# Initialize the ROOT direcotry variable
if [ $# -eq 1 ]
then
    ROOT=$1
elif [ $# -eq 0 ]
then
    ROOT=$HOME/algs4
    echo "Usage: algs4_dev [Course Root]"
fi

# Check if Javac is installed and available in $PATH
if ! (which javac &> /dev/null)
then
    echo "Java Compiler not found in \$PATH."
    echo "Please install any JDK before continuing"
    exit 1
fi

if ! (which unzip &> /dev/null)
then
    echo "Unzip command not found. Exiting..."
    exit 1
fi

# Decide Network download tool.
if (which wget &> /dev/null)
then
    DWN=wget
else
    echo "Wget not found. Please install Wget before contonuing"
    echo "I will not use Curl because of horrible syntax issues"
    exit 1
fi

# Create and move into the project ROOT
mkdir -p "$ROOT/bin"
cd "$ROOT"

# Download all nececarry files
# Uses a completely unmaintainable command for downloading all files because I'm
# bored
$DWN -c http://algs4.cs.princeton.edu/{linux/{drjava{,.jar},java{,c}-algs4,{checkstyle,findbugs}{-algs4,.{zip,xml}}},code/{stdlib,algs4}.jar}

# Find and replace all occurances of the default project root
if [ "$ROOT" != "$HOME/algs4" ]
then
    SROOT=$(echo $ROOT | sed 's_/_\\/_g')
    sed -i.bak "s/~\algs4/$SROOT/g" checkstyle-algs4
    sed -i.bak "s/~\algs4/$SROOT/g" drjava
    sed -i.bak "s/~\algs4/$SROOT/g" findbugs-algs4
    sed -i.bak "s/~\algs4/$SROOT/g" javac-algs4
    sed -i.bak "s/~\algs4/$SROOT/g" java-algs4
    #find . -type f -exec sed -i.bak "s/~\/algs4/$SROOT/g" {} \;
fi

chmod 700 drjava java{,c}-algs4 {checkstyle,findbugs}-algs4
mv drjava java{,c}-algs4 {checkstyle,findbugs}-algs4 bin/

unzip checkstyle.zip
unzip findbugs.zip

mv checkstyle.xml checkstyle-5.5
mv findbugs.xml findbugs-2.0.1

echo "Setting \$PATH variable for bin/ directory"
# Set the path variable
echo "export PATH=\"\$PATH:$ROOT/bin\"" >> "$HOME/.bashrc"

cd "$SPWD"

echo "Setting up bashrc file with helper functions"

# Download and install bash functions to compile
if [[ ! -f ./algs4_c.sh ]]
then
    wget "https://raw.githubusercontent.com/darnir/scripts/master/algs4_c.sh"
fi

bash ./algs4_c.sh

source "$HOME/.bashrc"
