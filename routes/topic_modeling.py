import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import CountVectorizer
from umap import UMAP
from hdbscan import HDBSCAN
from .rag_core import embed_batch
from .routes import STOPWORDS # Import STOPWORDS from routes.py


def c_tf_idf(documents, m, ngram_range=(1, 3)):
    """Calculate class-based TF-IDF scores"""
    count = CountVectorizer(ngram_range=ngram_range, stop_words=list(STOPWORDS), min_df=2).fit(documents)
    t = count.transform(documents).toarray()
    w = t.sum(axis=1)
    tf = np.divide(t.T, w)
    sum_t = t.sum(axis=0)
    idf = np.log(np.divide(m, sum_t)).reshape(-1, 1)
    tf_idf = np.multiply(tf, idf)
    return tf_idf, count

def extract_top_n_words_per_topic(tf_idf, count, docs_per_topic, n=5):
    """Extract top n words for each topic based on TF-IDF scores"""
    words = count.get_feature_names_out()
    labels = list(docs_per_topic.Topic)
    tf_idf_transposed = tf_idf.T
    indices = tf_idf_transposed.argsort()[:, -n:]
    top_n_words = {label: [(words[j], tf_idf_transposed[i][j]) for j in indices[i]][::-1] for i, label in enumerate(labels)}
    return top_n_words

def find_topic_clusters(texts: list[str], min_cluster_size: int = 2):
    """Main function to find semantic topic clusters from a list of texts."""
    print(f"\n--- [DEBUG] Running find_topic_clusters with {len(texts)} texts ---")
    if not texts or len(texts) < min_cluster_size:
        print(f"--- [DEBUG] Not enough texts to cluster. Required: {min_cluster_size}, Got: {len(texts)} ---")
        return []

    # 1. Generate Embeddings
    try:
        embeddings = embed_batch(texts)
        print(f"--- [DEBUG] Step 1/5: Generated {len(embeddings)} embeddings ---")
        if not embeddings:
            print("--- [DEBUG] Embedding process returned no embeddings. Aborting. ---")
            return []
    except Exception as e:
        print(f"--- [DEBUG] Error during embedding generation: {e} ---")
        return []

    # 2. Reduce Dimensionality with UMAP
    print("--- [DEBUG] Step 2/5: Reducing dimensionality with UMAP... ---")
    try:
        # Validate embeddings array
        embeddings = np.array(embeddings)
        if embeddings.size == 0 or len(embeddings) == 0:
            print("--- [DEBUG] Empty embeddings array. Cannot proceed with UMAP. ---")
            return []
        
        print(f"--- [DEBUG] Embeddings shape: {embeddings.shape} ---")
        
        # Adjust n_neighbors based on data size
        n_neighbors = min(15, len(embeddings) - 1)
        if n_neighbors < 2:
            print(f"--- [DEBUG] Too few samples for UMAP (need at least 2, got {len(embeddings)}). ---")
            return []
        
        umap_embeddings = UMAP(
            n_neighbors=n_neighbors,
            n_components=min(5, len(embeddings) - 1), # Ensure components <= samples
            min_dist=0.0,
            metric='cosine',
            random_state=42
        ).fit_transform(embeddings)
        print(f"--- [DEBUG] UMAP transformation complete. Shape: {umap_embeddings.shape} ---")
        
    except Exception as e:
        print(f"--- [DEBUG] UMAP transformation failed: {e} ---")
        return []

    # 3. Cluster with HDBSCAN
    print("--- [DEBUG] Step 3/5: Clustering with HDBSCAN... ---")
    try:
        # Validate UMAP embeddings
        if len(umap_embeddings) < min_cluster_size:
            print(f"--- [DEBUG] Not enough samples for clustering (need {min_cluster_size}, got {len(umap_embeddings)}). ---")
            return []
        
        clusterer = HDBSCAN(
            min_cluster_size=min_cluster_size,
            metric='euclidean',
            cluster_selection_method='eom'
        ).fit(umap_embeddings)
        print(f"--- [DEBUG] HDBSCAN found labels: {np.unique(clusterer.labels_)} ---")
        
    except Exception as e:
        print(f"--- [DEBUG] HDBSCAN clustering failed: {e} ---")
        return []

    # Prepare data for topic naming
    docs_df = pd.DataFrame(texts, columns=["Doc"])
    docs_df['Topic'] = clusterer.labels_
    docs_df['Doc_ID'] = range(len(docs_df))
    docs_per_topic = docs_df[docs_df.Topic != -1].groupby(['Topic'], as_index=False).agg({'Doc': ' '.join})
    print(f"--- [DEBUG] Step 4/5: Found {len(docs_per_topic)} topics (excluding noise points) ---")

    if docs_per_topic.empty:
        print("--- [DEBUG] No topics found after filtering noise. Aborting. ---")
        return []

    # 4. Name topics using c-TF-IDF
    try:
        tf_idf, count = c_tf_idf(docs_per_topic['Doc'], m=len(texts))
        top_n_words = extract_top_n_words_per_topic(tf_idf, count, docs_per_topic, n=5)
        topic_names = {key: ", ".join([word for word, val in values[:5]]) for key, values in top_n_words.items()}
        print(f"--- [DEBUG] Generated topic names: {topic_names} ---")
    except ValueError as e:
        # Fallback if TF-IDF fails (e.g., all stop words)
        print(f"--- [DEBUG] c-TF-IDF failed: {e}. Using fallback names. ---")
        topic_names = {topic: f"Topik {topic}" for topic in docs_per_topic.Topic}


    # 5. Aggregate results
    print("--- [DEBUG] Step 5/5: Aggregating final results... ---")
    # First, get the size of each cluster
    topic_sizes = docs_df[docs_df.Topic != -1].groupby(['Topic']).size().reset_index(name='count')
    # Merge with topic names
    topic_sizes['name'] = topic_sizes['Topic'].map(topic_names)
    
    # Sort by count and prepare final output
    top_topics = topic_sizes.sort_values('count', ascending=False).to_dict('records')
    print(f"--- [DEBUG] Final top_topics before return: {top_topics} ---")

    return top_topics


