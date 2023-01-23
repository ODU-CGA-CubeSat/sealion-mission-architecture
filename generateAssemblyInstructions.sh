#!/usr/bin/env bash

#### set environment variable for project root ####
project_root=$PWD

# Make dist/ directory, if none exists
if [ ! -r ./dist ]; then
    mkdir dist/
fi

#### generate dist/component.yaml & symlink to architecture/ directory ####
clitool="node"
cmdargs="dof-helpers/parseComponent.js"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "generating dist/component.yaml via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "generating dist/component.yaml..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate assembly instructions as asciidoc ####
clitool="node"
cmdargs="dof-helpers/generateAssemblyInstructions.js"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "generating assembly instructions as asciidoc via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "generating assembly instructions as asciidoc..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate assembly instructions as html ####
clitool="asciidoctor"
cmdargs="assemblyInstructions.adoc -o assemblyInstructions.html"
cmd="$clitool $cmdargs"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep '2.0.17'"

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
clitool="asciidoctor"
cmdargs="assemblyInstructions.adoc -o assemblyInstructions.pdf -r asciidoctor-pdf -b pdf"
cmd="$clitool $cmdargs"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep '2.0.17'"

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

