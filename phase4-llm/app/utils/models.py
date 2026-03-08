import joblib
import numpy as np
import re
from gensim.models import Word2Vec, KeyedVectors
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import streamlit as st
import nltk

# Download NLTK data if not present
nltk.download('wordnet', quiet=True)
nltk.download('stopwords', quiet=True)
nltk.download('omw-1.4', quiet=True)

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # utils/
BASE_DIR = os.path.dirname(BASE_DIR)                   # app/
BASE_DIR = os.path.dirname(BASE_DIR)                   # phase4-llm/
BASE_DIR = os.path.dirname(BASE_DIR)                   # analytics-pipeline/
MODEL_DIR = os.path.join(BASE_DIR, 'data', 'models')

import sys
print(f"__file__: {os.path.abspath(__file__)}", file=sys.stderr)
print(f"MODEL_DIR: {MODEL_DIR}", file=sys.stderr)

GLOVE_PATH = os.path.join(BASE_DIR, 'data', 'glove_wiki_gigaword_100.model')

@st.cache_resource
def load_models():
    models = {}
    
    # Preprocessing
    stop_words = joblib.load(f'{MODEL_DIR}/stop_words.pkl')
    lemmatizer = joblib.load(f'{MODEL_DIR}/lemmatizer.pkl')
    
    # VADER
    models['vader'] = SentimentIntensityAnalyzer()
    
    # TF-IDF
    models['tfidf_vectorizer'] = joblib.load(f'{MODEL_DIR}/tfidf_vectorizer.pkl')
    models['tfidf_linearsvc'] = joblib.load(f'{MODEL_DIR}/tfidf_linearsvc_tuned.pkl')
    
    # Word2Vec
    models['w2v'] = Word2Vec.load(f'{MODEL_DIR}/word2vec.model')
    models['w2v_clf'] = joblib.load(f'{MODEL_DIR}/w2v_linearsvc_balanced.pkl')
    
    # GloVe
    try:
        models['glove'] = KeyedVectors.load(GLOVE_PATH)
        models['glove_clf'] = joblib.load(f'{MODEL_DIR}/glove_linearsvc_balanced.pkl')
        models['has_glove'] = True
    except:
        models['has_glove'] = False
    
    return models, stop_words, lemmatizer

def clean_text(text, stop_words, lemmatizer):
    text = text.lower()
    text = re.sub(r'[^a-z\s]', '', text)
    tokens = [lemmatizer.lemmatize(w) for w in text.split()
              if w not in stop_words and len(w) > 2]
    return ' '.join(tokens)

def document_vector(tokens, model):
    wv = model.wv if hasattr(model, 'wv') else model
    valid_tokens = [t for t in tokens if t in wv]
    if not valid_tokens:
        return np.zeros(wv.vector_size)
    return np.mean(wv[valid_tokens], axis=0)

def predict_vader(text, models):
    scores = models['vader'].polarity_scores(text)
    compound = scores['compound']
    if compound >= 0.05:
        sentiment = 'positive'
    elif compound <= -0.05:
        sentiment = 'negative'
    else:
        sentiment = 'neutral'
    return sentiment, compound

def predict_tfidf(text, models, stop_words, lemmatizer):
    cleaned = clean_text(text, stop_words, lemmatizer)
    # Vectorize first, then pipeline (scaler + clf)
    vectorized = models['tfidf_vectorizer'].transform([cleaned])
    pred = models['tfidf_linearsvc'].predict(vectorized)[0]
    return int(pred)

def predict_w2v(text, models):
    tokens = text.lower().split()
    vec = document_vector(tokens, models['w2v']).reshape(1, -1)
    pred = models['w2v_clf'].predict(vec)[0]
    return int(pred)

def predict_glove(text, models):
    tokens = text.lower().split()
    vec = document_vector(tokens, models['glove']).reshape(1, -1)
    pred = models['glove_clf'].predict(vec)[0]
    return int(pred)