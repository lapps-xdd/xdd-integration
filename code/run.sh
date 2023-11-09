# Script that runs all xDD pre-processing
# =============================================================================

# We first pull any new commits from GitHub and go to the top of the develop
# branch (for the final version we will stay in the main branch).

branch=main

echo "\n>>> Updating xdd-docstructure"
cd code/xdd-docstructure
git pull --quiet
git checkout $branch --quiet

echo "\n>>> Updating xdd-processing"
cd ../xdd-processing
git pull --quiet
git checkout $branch --quiet

echo "\n>>> Updating xdd-terms"
cd ../xdd-terms
git pull --quiet
git checkout $branch --quiet

# Pre-processing

echo "\n>>> Running document structure parser"
cd ../xdd-docstructure/code
python parse.py --scpa /data/scienceparse --text /data/text --out /data/output/doc

echo "\n>>> Running spaCy NER"
cd ../../xdd-processing/code
python ner.py --doc /data/output/doc --pos /data/output/pos --ner /data/output/ner

echo "\n>>> Running term extraction"
cd ../../xdd-terms/code
python pos2phr.py -i /data/output/pos
python accumulate.py -i /data/output/trm

# Merging

echo "\n>>> Merging layers"
cd ../../xdd-processing/code
python merge.py \
	--scpa /data/scienceparse --doc /data/output/doc --ner /data/output/ner \
	--trm /data/output/trm --meta /data/metadata.json --out /data/output/mer

# Creation of JSON file for ElasticSearch

echo "\n>>> Creating ElasticSearch file"
python prepare_elastic.py -i /data/output/mer -o /data/output/ela
