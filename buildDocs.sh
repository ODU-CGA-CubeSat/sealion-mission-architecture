#!/usr/bin/env bash

#### set environment variable for project root ####
project_root=$PWD

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

#### Install m30mlTools/node_modules, if not already installed ####
if [ ! -r ./node_modules ]; then
    clitool="npm"
    cmdargs="ci"
    cmd="$clitool $cmdargs"
    workdir=$project_root/m30mlTools
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

#### Install dof-helpers/node_modules, if not already installed ####
if [ ! -r ./dof-helpers/node_modules ]; then
    clitool="npm"
    cmdargs="ci"
    cmd="$clitool $cmdargs"
    workdir=$project_root/dof-helpers
    podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
    condition="$clitool --help | grep 'npm <command>'"

    if ! eval $condition; then
        echo "Installing dof-helpers/node_modules via podman..."
        cd $project_root
        eval $(echo $podmancmd)
    else
        echo "Installing dof-helpers/node_modules..."
        cd $workdir
        eval $cmd
        cd $project_root
    fi
fi

#### Create dist/ directory, if none exists ####
if [ ! -r ./dist ]; then
    echo "Creating dist/ directory..."
    mkdir dist/
fi

# copy operating-mode-as-fsm.puml to dist/...
echo "copying operating-mode-as-fsm.puml to dist/..."
cp ./components/sealion-cubesat/components/sealion-obc/components/dilophos/fsw-architecture/operating-mode-as-fsm.puml dist/

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

echo "Create symlink to dist/component.yaml in architecture/4-Components..."
mkdir architecture/4-Components
ln -srv dist/component.yaml architecture/4-Components

#### generate assembly instructions ####
clitool="node"
cmdargs="dof-helpers/generateAssemblyInstructions.js"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "generating assembly instructions via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "generating assembly instructions..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Build the unified model from liquid template ####
clitool="node"
cmdargs="m30mlTools/buildUnifiedModel.js"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Building the unified model from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Building the unified model from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

# Create symlink to dist/architecture.yaml as dist/architecture.yml
echo "Creating symlink to dist/architecture.yaml as dist/architecture.yml..."
ln -srv dist/architecture.yaml dist/architecture.yml

#### Generate stakeholder needs mapping from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/stakeholder-needs-mapping.puml.liquid --out=dist/stakeholder-needs-mapping.puml"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating stakeholder needs mapping from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating stakeholder needs from liquid template mapping..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate user stories mapping from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/user-stories-mapping.puml.liquid --out=dist/user-stories-mapping.puml"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating user stories mapping from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating user stories mapping from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate use-case-diagrams.puml from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/use-case-diagram.puml.liquid --out=dist/use-case-diagram.puml"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating use-case-diagrams.puml from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating use-case-diagrams.puml from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate data structure mapping from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/data-structures-mapping.puml.liquid --out=dist/data-structures-mapping.puml"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating data structure mapping from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating data structure mapping from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate sealion-mission-architecture.adoc from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/sealion-mission-architecture.adoc.liquid --out=dist/sealion-mission-architecture.adoc"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating sealion-mission-architecture.adoc from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating sealion-mission-architecture.adoc from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate pdf-theme.yml from liquid template ####
clitool="jinja2"
cmdargs="-o dist/pdf-theme.yml --format yaml templates/pdf-theme.yml.jinja2 dist/architecture.yml"
workdir=$project_root
cmd="$clitool $cmdargs"
podmancmd="podman run --rm -v $workdir:/work -w /work docker.io/roquie/docker-jinja2-cli $cmdargs"
condition="$clitool --version | grep 'v0.8.2'"

if ! eval $condition; then
    echo "Generating pdf-theme.yml from jinja2 template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating pdf-theme.yml from jinja2 template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate index.html from dist/sealion-mission-architecture.adoc ####
clitool="asciidoctor"
cmdargs="dist/sealion-mission-architecture.adoc -r asciidoctor-diagram -o dist/index.html"
workdir=$project_root
cmd="$clitool $cmdargs"
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep '2.0.17'"

if ! eval $condition; then
    echo "Generating index.html from dist/sealion-mission-architecture.adoc via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating index.html from dist/sealion-mission-architecture.adoc..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate sealion-mission-architecture.pdf from dist/sealion-mission-architecture.adoc ####
clitool="asciidoctor"
cmdargs="dist/sealion-mission-architecture.adoc -o dist/sealion-mission-architecture.pdf -r asciidoctor-pdf -r asciidoctor-diagram -b pdf -a pdf-theme=dist/pdf-theme.yml"
workdir=$project_root
cmd="$clitool $cmdargs"
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep '2.0.17'"

if ! eval $condition; then
    echo "Generate sealion-mission-architecture.pdf from dist/sealion-mission-architecture.adoc via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generate sealion-mission-architecture.pdf from dist/sealion-mission-architecture.adoc..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

# remove architecture/4-Components
echo "removing architecture/4-Components..."
rm -rf architecture/4-Components

## Generate presentation.html
#echo "Generating presentation.adoc..."
#podman run --rm -v $PWD:/src -w /src node node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/presentation.adoc.liquid --out=dist/presentation.adoc
#echo "Generating presentation.html..."
#podman run --rm -v $PWD:/documents asciidoctor/docker-asciidoctor bash -c "cd dist && asciidoctor-revealjs -r asciidoctor-diagram -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 -a revealjs_transition=slide -a revealjs_slideNumber=true -a revealjs_width=1100 -a revealjs_height=700 -D . 'presentation.adoc' -o 'presentation.html'"

#### Generate tabulated-stakeholder-needs.adoc from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/tabulated-stakeholder-needs.adoc.liquid --out=dist/tabulated-stakeholder-needs.adoc"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating tabulated-stakeholder-needs.adoc from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating tabulated-stakeholder-needs.adoc from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

## create symbolic link for tabulated-stakeholder-needs.adoc
#echo "create symbolic link for tabulated-stakeholder-needs.adoc in research/..."
#podman run --rm --volume "$PWD:/src" -w "/src" node bash -c 'ln -srv dist/tabulated-stakeholder-needs.adoc research/tabulated-stakeholder-needs.adoc'

#### Generate tabulated-user-stories.adoc from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/tabulated-user-stories.adoc.liquid --out=dist/tabulated-user-stories.adoc"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating tabulated-user-stories.adoc from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating tabulated-user-stories.adoc from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

## create symbolic link for tabulated-user-stories.adoc
#echo "create symbolic link for tabulated-user-stories.adoc in research/..."
#podman run --rm --volume "$PWD:/src" -w "/src" node bash -c 'ln -srv dist/tabulated-user-stories.adoc research/tabulated-user-stories.adoc'

#### Generate satellite-health-data.adoc from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/satellite-health-data.adoc.liquid --out=dist/satellite-health-data.adoc"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating satellite-health-data.adoc from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating satellite-health-data.adoc from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate satellite-health-data.adoc from liquid template ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/satellite-health-data.adoc.liquid --out=dist/satellite-health-data.adoc"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating satellite-health-data.adoc from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating satellite-health-data.adoc from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### Generate LaTeX code for satellite health data packet table ####
clitool="node"
cmdargs="m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/satellite-health-data-packet-as-table.tex.liquid --out=dist/satellite-health-data-packet-as-table.tex"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm --volume $workdir:/srv -w /srv docker.io/node $cmd"
condition="$clitool --version | grep 'v17'"

if ! eval $condition; then
    echo "Generating satellite-health-data-packet.tex from liquid template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating satellite-health-data-packet.tex from liquid template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate example manuscript ####
# for linkml podman command usage, see https://hub.docker.com/r/linkml/linkml
clitool="linkml-validate"
cmdargs="-s manuscript-metamodel.yaml manuscript-example.yaml"
cmd="$clitool $cmdargs"
workdir=$project_root/manuscript
podmancmd="podman run --rm -v $workdir:/work -w /work docker.io/linkml/linkml:1.3.14 $cmd"
condition="$clitool --help | grep 'Validates instance data'"

if ! eval $condition; then
    echo "Validating linkml model of example manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Validating linkml model of example manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

clitool="jinja2"
cmdargs="-o dist/manuscript-example.tex --format yaml templates/manuscript.tex.jinja2 manuscript/manuscript-example.yaml"
workdir=$project_root
#cmdargs="-o dist/title.tex --format yaml templates/title.tex.jinja2 manuscript/manuscript-example.yaml"
cmd="$clitool $cmdargs"
podmancmd="podman run --rm -v $workdir:/work -w /work docker.io/roquie/docker-jinja2-cli $cmdargs"
condition="$clitool --version | grep 'v0.8.2'"

if ! eval $condition; then
    echo "Generating LaTeX document from example manuscript linkml model and jinja2 template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating LaTeX document from example manuscript linkml model and jinja2 template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

echo "Copy LaTeX files and assets (required for generating PDF document) to dist/..."

cp -t dist/ manuscript/*.tex manuscript/*.bib manuscript/*.bst manuscript/*.cls assets/*

# https://tex.stackexchange.com/questions/43325/citations-not-showing-up-in-text-and-bibliography
cmd="pdflatex manuscript-example.tex && bibtex manuscript-example.aux"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/nanozoo/pdflatex:3.14159265--f2f4a3f bash -c '$cmd'"

if [ ! $(pdflatex -version | grep '3.14159265') && ! $(bibtex -version | grep '0.99d') ]; then
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
cmd="pdflatex manuscript-example.tex && pdflatex manuscript-example.tex"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/nanozoo/pdflatex:3.14159265--f2f4a3f bash -c '$cmd'"

if [ ! $(pdflatex -version | grep '3.14159265') && ! $(bibtex -version | grep '0.99d') ]; then
    echo "Generating PDF document from LaTeX/BibTeX document of example manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating PDF document from LaTeX/BibTeX document of example manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

#### generate manuscript ####
# for linkml docker command usage, see https://hub.docker.com/r/linkml/linkml
clitool="linkml-validate"
cmdargs="-s manuscript-metamodel.yaml manuscript.yaml"
cmd="$clitool $cmdargs"
workdir=$project_root/manuscript
podmancmd="podman run --rm -v $workdir:/work -w /work docker.io/linkml/linkml:1.3.14 $cmd"
condition="$clitool --help | grep 'Validates instance data'"

if ! eval $condition; then
    echo "Validating linkml model of manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Validating linkml model of manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

clitool="jinja2"
cmdargs="-o dist/manuscript.tex --format yaml templates/manuscript.tex.jinja2 manuscript/manuscript.yaml"
#cmdargs="-o dist/title.tex --format yaml templates/title.tex.jinja2 manuscript/manuscript.yaml"
cmd="$clitool $cmdargs"
workdir=$project_root
podmancmd="podman run --rm -v $workdir:/work -w /work docker.io/roquie/docker-jinja2-cli $cmdargs"
condition="$clitool --version | grep 'v0.8.2'"

if ! eval $condition; then
    echo "Generating LaTeX document from manuscript linkml model and jinja2 template via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating LaTeX document from manuscript linkml model and jinja2 template..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

echo "Copy LaTeX files and assets (required for generating PDF document) to dist/..."

cp -t dist/ manuscript/*.tex manuscript/*.bib manuscript/*.bst manuscript/*.cls assets/*

# https://tex.stackexchange.com/questions/43325/citations-not-showing-up-in-text-and-bibliography
cmd="pdflatex manuscript.tex && bibtex manuscript.aux"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/nanozoo/pdflatex:3.14159265--f2f4a3f bash -c '$cmd'"

if [ ! $(pdflatex -version | grep '3.14159265-2.6-1.40.19') ] && [ ! $(bibtex -version | grep '0.99d') ]; then
    echo "Pre-Processing LaTeX document with BibTeX of manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Pre-Processing LaTeX document with BibTeX of manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

# https://tex.stackexchange.com/questions/43325/citations-not-showing-up-in-text-and-bibliography
cmd="pdflatex manuscript.tex && pdflatex manuscript.tex"
workdir=$project_root/dist
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/nanozoo/pdflatex:3.14159265--f2f4a3f bash -c '$cmd'"

if [ ! $(pdflatex -version | grep '3.14159265-2.6-1.40.19') ] && [ ! $(bibtex -version | grep '0.99d') ]; then
    echo "Generating PDF document from LaTeX/BibTeX document of manuscript via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generating PDF document from LaTeX/BibTeX document of manuscript..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

gitdescribe=$(git describe --always --tags HEAD)
newmanuscriptname=manuscript-$gitdescribe.pdf
mv $workdir/manuscript.pdf $workdir/$newmanuscriptname

# Copy scitech-presentation.adoc to dist/
cp -t dist/ manuscript/scitech-presentation.adoc assets/* -r themes/

#### Generate scitech-presentation.html from dist/scitech-presentation.adoc ####
clitool="asciidoctor-revealjs"
cmdargs="-r asciidoctor-diagram -a revealjs_transition=slide -a revealjs_slideNumber=true -a revealjs_width=1100 -a revealjs_height=700 'scitech-presentation.adoc' -o 'scitech-presentation.html'"
workdir=$project_root/dist
cmd="$clitool $cmdargs"
podmancmd="podman run --rm -v $workdir:/srv -w /srv docker.io/asciidoctor/docker-asciidoctor $cmd"
condition="$clitool --version | grep 'v'"

if ! eval $condition; then
    echo "Generate scitech-presentation.html from dist/sealion-mission-architecture.adoc via podman..."
    cd $project_root
    eval $(echo $podmancmd)
else
    echo "Generate scitech-presentation.html from dist/sealion-mission-architecture.adoc..."
    cd $workdir
    eval $cmd
    cd $project_root
fi

# Copy reveal.js to dist/
cp -r reveal.js/ dist/
