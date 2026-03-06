import gensim.downloader as api
import nltk
import os

# Download GloVe vectors
GLOVE_PATH = '/app/data/glove_wiki_gigaword_100.model'

if os.path.exists(GLOVE_PATH):
    print("GloVe model already exists, skipping download")
else:
    print("Downloading GloVe vectors (this may take a few minutes)...")
    glove_model = api.load('glove-wiki-gigaword-100')
    glove_model.save(GLOVE_PATH)

# Download NLTK data
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('omw-1.4')

# docker exec -it analytics-pipeline-llm-app-1 python /app/download_models.py    