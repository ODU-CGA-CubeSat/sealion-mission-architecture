#!/usr/bin/env bash

#### set environment variable for project root ####
project_root=$PWD
node_modules_path=$(readlink -f node_modules)
dof_helpers_path=$(readlink -f dof-helpers)
asciidoctor_path="asciidoctor"

# Make dist/ directory, if none exists
if [ ! -r ./dist ]; then
    mkdir dist/
fi

#### Install node_modules, if not already installed ####
if [ ! -r ./node_modules ]; then
    clitool="npm"
    cmdargs="ci"
    cmd="$clitool $cmdargs"
    workdir=$project_root
    podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
    condition="$clitool --help | grep 'npm <command>'"

    if ! eval $condition; then
        echo "Installing node_modules via podman..."
        cd $project_root
        eval $(echo $podmancmd)
    else
        echo "Installing node_modules..."
        cd $workdir
        eval $cmd
        cd $project_root
    fi
fi

# copy node_modules into dist/
cp -r $node_modules_path ./dist

#### generate dist/component.yaml & symlink to architecture/ directory ####
clitool="node"
cmdargs="$dof_helpers_path/parseComponent.js"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmdargs"
condition="$clitool --version | grep 'v18.5.0'"

if ! eval $condition; then
    echo "generating dist/component.yaml via podman..."
    cd $project_root
    eval $podmancmd
else
    echo "generating dist/component.yaml..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate assembly instructions as asciidoc ####
clitool="node"
cmdargs="$dof_helpers_path/generateAssemblyInstructions.js"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmdargs"
condition="$clitool --version | grep 'v18.5.0'"

if ! eval $condition; then
    echo "generating assembly instructions as asciidoc via podman..."
    cd $project_root
    eval $podmancmd
else
    echo "generating assembly instructions as asciidoc..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate assembly instructions as html ####
clitool=$asciidoctor_path
cmdargs="assemblyInstructions.adoc -o assemblyInstructions.html"
cmd="$clitool $cmdargs"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep '2.0.18'"

if ! eval $condition; then
    echo "generating assembly instructions as html via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "generating assembly instructions as html..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate assembly instructions as pdf ####
clitool=$asciidoctor_path
cmdargs="assemblyInstructions.adoc -o assemblyInstructions.pdf -r asciidoctor-pdf -b pdf"
cmd="$clitool $cmdargs"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep '2.0.18'"

if ! eval $condition; then
    echo "generating assembly instructions as pdf via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "generating assembly instructions as pdf..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

