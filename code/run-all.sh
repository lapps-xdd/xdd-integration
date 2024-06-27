# Script that runs all xDD pre-processing
# =============================================================================

# Uses three repositories that were already cloned in the image, but are updated
# if needed when this script runs.
#
# Usage:
#
#    $ sh run.sh
#
# This runs all xDD processing on the data
#
# Advanced usage:
#
#    $ sh run.sh [-t TAG] [-b BRANCH]
#
# The -t and -b options are only relevant if you are experimenting with the code,
# for anyone else a simple "sh run.sh" is sufficient. If a TAG is specified then
# that tag will be checked out, otherwise if a BRANCH was specified then the top
# of that branch will be checked out, otherwise the main branch will be checked out.
#
# We allow for some configuration on what commit to select
#
# - First do a "git pull --all"
# - Then check whether we are using a branch or a tag
# - Case 1: no arguments
#              we are assuming we use the main branch and usually nothing needs done
#              but in case we run this script several times we need to checkout and
#              pull the branch for each repo
#              $ git checkout main
#              $ git pull
# - Case 2: branch was selected, eg "runs.sh -b develop"
#              then check out that branch for each repo and pull it
#              $ git checkout develop
#              $ git pull
# - Case 3: tags were selected, eg "run,sh "-s v1:v3.0:v2.1""
#              then for each repo we checkout the tag, the order is
#              "xdd-docstructure-tag:xdd-processing-tag:xdd-terms-tag"
#              so with the above example we cd into the docstructure repo and do
#              $ git checkout v1
#
# We do not account for any other configurations, so it is either all the same
# branch or some combination of tags

branch=develop


while getopts "t:b:" option; do
    case "${option}" in
        t) tag=${OPTARG} ;;
        b) branch=${OPTARG} ;;
        *) echo "unknown option" ;;
    esac
done

echo "branch ${branch}"
echo "tag ${tag}"

# Check out the tagged commit from GitHub or check out the top of the branch.

echo ">>> Updating repositories"

cd code
for repo in xdd-docstructure xdd-processing xdd-llms xdd-terms; do
       echo "${repo}"
       cd $repo
       git pull --all --quiet
       if ! [ -z ${tag+x} ]; then
               git checkout $tag --quiet
       else
	    	   git checkout $branch --quiet
               git pull --quiet
       fi
       cd ..
done


# Pre-processing

echo "\n>>> Running document structure parser"
cd xdd-docstructure/code
python parse.py --scpa /data/scienceparse --text /data/text --out /data/output/doc

echo "\n>>> Running spaCy NER"
cd ../../xdd-processing/code
python ner.py --doc /data/output/doc --pos /data/output/pos --ner /data/output/ner

echo "\n>>> Running term extraction"
cd ../../xdd-terms/code
python pos2phr.py --pos /data/output/pos --out /data/output/trm
python accumulate.py --terms /data/output/trm

echo "\n>>> Running Llama summarizer"
systemctl start ollama
cd ../../xdd-llms/
python -m run_llm.run_ollama --doc /data/output/doc --sum /data/output/sum


# Merging

echo "\n>>> Merging layers"
cd ../xdd-processing/code
python merge.py \
	--scpa /data/scienceparse --doc /data/output/doc --ner /data/output/ner \
	--trm /data/output/trm --meta /data/metadata.json --out /data/output/mer

# Creation of JSON file for ElasticSearch

echo "\n>>> Creating ElasticSearch file"
python prepare_elastic.py -i /data/output/mer -o /data/output/ela
