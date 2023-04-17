#!/usr/bin/env bash
################################################################
# Build script for building unified model, architecture (spec doc), AIAA manuscript, & assembly instructions in dist/
################################################################

#### set environment variable for project root ####
project_root=$PWD

#### convert bib references to yaml to bibtex ####
# clitool="jinja2"
# cmdargs="-o references.tex --format yaml references.tex.jinja2 references.yaml"
# workdir=$project_root
# cmd="$clitool $cmdargs"
# podmancmd="podman run --rm -v $workdir:/work -w /work docker.io/roquie/docker-jinja2-cli $cmdargs"
# condition="$clitool --version | grep 'v0.8.2'"

# if ! eval $condition; then
#     echo "Generating LaTeX references via podman"
#     cd $project_root
#     eval $(echo $podmancmd)
# else
#     echo "Generating LaTeX references"
#     cd $workdir
#     eval $cmd
#     cd $project_root
# fi

#### generate example manuscript ####
# https://tex.stackexchange.com/questions/43325/citations-not-showing-up-in-text-and-bibliography
cmd="pdflatex template.tex && bibtex template.aux"
workdir=$project_root/
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/nanozoo/pdflatex:3.14159265--f2f4a3f bash -c '$cmd'"

if [ ! $(pdflatex -version | grep '3.14159265') ] && [ ! $(bibtex -version | grep '0.99d') ]; then
    echo $(pdflatex -version)
    echo $(bibtex -version)
    echo "Pre-Processing LaTeX document with BibTeX of example manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Pre-Processing LaTeX document with BibTeX of example manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

# https://tex.stackexchange.com/questions/43325/citations-not-showing-up-in-text-and-bibliography
cmd="pdflatex template.tex && pdflatex template.tex"
workdir=$project_root/
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/nanozoo/pdflatex:3.14159265--f2f4a3f bash -c '$cmd'"

if [ ! $(pdflatex -version | grep '3.14159265') ] && [ ! $(bibtex -version | grep '0.99d') ]; then
    echo "Generating PDF document from LaTeX/BibTeX document of example manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating PDF document from LaTeX/BibTeX document of example manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi
