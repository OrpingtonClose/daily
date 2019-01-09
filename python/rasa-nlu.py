#echo 'export PATH=$PATH:/home/orpington/.local/bin' | tee -a ~/.profile | sh
#pip3 install rasa_nlu --user
#pip3 install coloredlogs --user #enables colored terminal output for Python’s logging module
#pip3 install sklearn_crfsuite --user #scikit-learn compatible estimator: you can use e.g. scikit-learn model selection utilities (cross-validation, hyperparameter optimization) with it, or save/load CRF models using joblib.
#sudo pip3 install spacy
#sudo python3 -m spacy download en

BASE=$PWD

git clone https://github.com/RasaHQ/rasa_nlu.git #Clone the repo
cd rasa_nlu #Get into the rasa directory
pip2 install -r alt_requirements/requirements_full.txt #Install full requirements
python -m spacy download en
pip2 install coloredlogs sklearn_crfsuite

mkdir $BASE/data
cat > $BASE/data/data.json <<EOF
{
  "rasa_nlu_data": {
    "common_examples": [
      {"text": "hello","intent": "greeting","entities": []},
      {"text": "hi","intent": "greet","entities": []},
      {"text": "I'm looking for a place to eat","intent": "restaurant_search","entities": []},
      {"text": "I'm looking for a place in the north of town","intent": "restaurant_search","entities": []},
      {"text": "Show me chinese restaurants","intent": "restaurant_search",
       "entities": [{"start": 8,"end": 15,"value": "chinese","entity": "location"}]
      },
      {"text": "yes","intent": "affirm","entities": []},
      {"text": "yep","intent": "affirm","entities": []},
      {"text": "yeah","intent": "affirm","entities": []},
      {"text": "Show me a mexican place in the centre","intent": "restaurant_search",
       "entities": [{"start": 10,"end": 17,"value": "mexican","entity": "location"}]
      },
      {"text": "bye","intent": "goodby","entities":[]}
    ],
    "regex_features": [],
    "entity_synonyms": []
  }
}
EOF

sudo npm i -g rasa-nlu-trainer
~/.npm-global/bin/rasa-nlu-trainer

cat > $BASE/config.yml <<EOF
language: "en"    
pipeline:    
  - name: "nlp_spacy" 
  - name: "tokenizer_spacy"
  - name: "intent_entity_featurizer_regex"    
  - name: "intent_featurizer_spacy"    
  - name: "ner_crf"    
  - name: "ner_synonyms"    
  - name: "intent_classifier_sklearn"
EOF

python -m rasa_nlu.train \
       --config $BASE/config.yml \
       --data $BASE/data/data.json \
       --path projects

python -m rasa_nlu.server --path projects &

curl -X POST localhost:5000/parse -d '{"q":"I am looking for mexican food"}' | jq '.entities'
curl 'http://localhost:5000/version1?query=Can I get an Americano'

curl -X POST localhost:5000/parse -d '{"q":"Show me a mexican place in the centre"}' | jq '.entities'
curl -X POST localhost:5000/parse -d '{"q":"I am looking for mexican"}' | jq '.entities'


