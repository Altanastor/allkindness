from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
from gensim import corpora
import string
import gensim
import sys


def read_corpus(filenames):
    """
    read multiple files into list of strings
    :param filenames: list of files containing corpora of different category descriptions,
    one category per file
    :return: list of strings, one doc into one string
    """
    docs = []
    for filename in filenames:
        with open(filename, 'r', encoding='utf-8') as f:
            doc = ''
            for line in f.readlines():
                if line:
                    doc += line.strip()
            docs.append(doc)
    return docs


def clean(doc):
    """
    remove stopwords and lemmatize text
    :param doc: string to be cleaned
    :return: same string, cleaned
    """
    stop = set(stopwords.words('english'))
    exclude = set(string.punctuation)
    lemma = WordNetLemmatizer()
    stop_free = " ".join([i for i in doc.lower().split() if i not in stop])
    punc_free = ''.join(ch for ch in stop_free if ch not in exclude)
    normalized = " ".join(lemma.lemmatize(word) for word in punc_free.split())
    return normalized


def build_lda(docs_list, num_topic, num_word):
    """
    extract topic words from documents
    :param docs_list: list of strings (documents) to build LDA model on
    :param num_topic: desired number of topics per document
    :param num_word: desired number of words per topic
    :return: list (per collection) of lists (per document) of topics
    """
    dictionary = corpora.Dictionary(docs_list)
    topics_list = []
    for doc in docs_list:
        doc_term_matrix = [dictionary.doc2bow(doc)]
        Lda = gensim.models.ldamodel.LdaModel
        ldamodel = Lda(doc_term_matrix, num_topics=num_topic, id2word=dictionary, passes=50)
        topics_list.append(ldamodel.print_topics(num_topics=num_topic, num_words=num_word))
    return topics_list


def process_corpus(filenames):
    """
    extract topic words for each category of documents
    :param filenames: list of files, each of which contains training texts of one category
    :return: dict, keys are filenames, values are sets of topic words associated with each filename
    """
    docs = read_corpus(filenames)
    docs_clean = [clean(doc).split() for doc in docs]
    topics_list = build_lda(docs_clean, 2, 5)
    topics_dict = {filename: [] for filename in filenames}
    for n, doc in enumerate(topics_list):
        word_list = []
        for topic in doc:
            words = topic[1].split('"')
            for i, word in enumerate(words):
                if i % 2 != 0:
                    word_list.append(word)
        topics_dict[filenames[n]] = set(word_list)
    return topics_dict


def process_input(input_text):
    """
    find topic words in a new description text
    :param input_file: file containing string to process
    :return: set of topic words of the text
    """
    input_doc = [input_text]
    input_clean = [clean(doc).split() for doc in input_doc]
    topics_list = build_lda(input_clean, 2, 5)
    word_list = []
    for topic in topics_list[0]:
        words = topic[1].split('"')
        for i, word in enumerate(words):
            if i % 2 != 0:
                word_list.append(word)
    return set(word_list)


def similarity(input_file, filenames=['nature.txt','children.txt','pets.txt','inneed.txt']):
    """
    find the most fitting category for a new text
    :param input_text: string (description to be processed)
    :param filenames: category subcorpora files, one file per category
    :return: filename of the most similar category subcorpus
    """
    with open(input_file, 'r', encoding='utf-8') as f:
        input_text = f.read()
    cat_dict = process_corpus(filenames)
    input_topic = process_input(input_text)
    sim_dict = {filename: len(cat_dict[filename].intersection(input_topic)) for filename in filenames}
    v = list(sim_dict.values())
    k = list(sim_dict.keys())
    return k[v.index(max(v))]

if __name__ == "__main__":
    corpus, new_input = sys.argv[1], sys.argv[2]
    corpus = [str(filename) for filename in corpus.split(',')]
    print(similarity(new_input, corpus))
