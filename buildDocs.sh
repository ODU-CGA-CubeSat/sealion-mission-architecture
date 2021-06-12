#!/usr/bin/env bash

# first, copy over any extra shortcodes, like the pdf embedded shortcode
# https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-directory-does-not-already-exist

if [ ! -r ./docs/themes/geekdoc/node_modules ]; then
    docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/hugo-asciidoctor-plantuml:0.82.0-alpine 'cd docs/themes/geekdoc && npm ci'
fi
if [ ! -r ./docs/themes/geekdoc/build ]; then
    docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/hugo-asciidoctor-plantuml:0.82.0-alpine 'cd docs/themes/geekdoc && npx gulp default'
fi
if [ ! -r ./docs/public ]; then
    docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/hugo-asciidoctor-plantuml:0.82.0-alpine 'cd docs && hugo --minify -v --destination public'
fi
