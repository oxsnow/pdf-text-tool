from flask import Flask, request, jsonify
from flask_executor import Executor
from collections import Counter
import os
import csv
import PyPDF2
import pymupdf
from datetime import datetime
import re
import sys
from concurrent.futures import ThreadPoolExecutor
import threading
sys.stdout.reconfigure(encoding='utf-8')

app = Flask(__name__)
executor = Executor(app)
lock = threading.Lock()  # Mutex lock for shared resources
sentence_lock = threading.Lock()  # Mutex lock for shared resources
MAX_THREADS = 1  # Set the number of threads allowed

word_count_results = {}
task_status = {}
resultMap = {}
sentencesFileName = ""
summaryFileName = ""

cpu_count = os.cpu_count()

importFileName = "import.txt"

wordPerFile = {}

def extract_year(text):
    # Try to match YYYY-YY format first
    match = re.search(r"\b(\d{4})-\d{2}\b", text)
    if match:
        return match.group(1)
    
    # If no YYYY-YY match, try standalone YYYY format
    match = re.search(r"\b(\d{4})\b", text)
    return match.group(1) if match else "-"

def extract_ticker_and_year(filename):
    # Split the filename into parts
    parts = filename.split('_')

    # Check if the filename matches the expected format
    if len(parts) == 3:
        ticker = parts[0]
        year = extract_year(parts[2])
    else:
        ticker = filename
        year = "-"

    return ticker, year

def parse_query(query):
    """
    Parses the search query and returns structured components.
    Converts '/' to OR, '&' to AND while maintaining parentheses.
    
    :param query: Boolean search query as a string.
    :return: Parsed query suitable for regex searching.
    """
    re.sub(r'\s*"\s*', '"', query) #remove space before and after quote
    query = query.replace(" OR", "OR")  # Replace OR operator space
    query = query.replace("OR ", "OR")  # Replace OR operator space
    query = query.replace("OR", "|")  # Replace OR operator
    query = query.replace(" AND", "AND")  # Replace AND operator spaces
    query = query.replace("AND ", "AND")  # Replace AND operator spaces
    query = query.replace("AND", ".*")  # Replace AND operator with regex sequence
    query = query.replace('" ','"') #remove spaces in quote
    query = query.replace(' "','"') #remove spaces in quote
    query = query.replace('"','') #remove quote
    print(query)
    return query

def search_sentences(split_sentences, formatted_queries, sentences):
    def process_sentence(sentenceIndex, sentence):
        matches = [query.search(sentence) for query in formatted_queries]
        for count, match in enumerate(matches):
            if match:
                sentences[count].append(sentence.replace(",", "").replace(";", "").strip())

    # Use thread pool for concurrent sentence scanning
    with ThreadPoolExecutor(max_workers=cpu_count) as executor:
        executor.map(process_sentence, range(len(split_sentences)), split_sentences)


def count(paths, keywords):
    global resultMap, sentencesFileName, summaryFileName, wordPerFile
    
    # Ensure thread safety when modifying global variables
    with lock:
        resultMap.clear()
        wordPerFile.clear()

    formatted_queries = [re.compile(parse_query(query), re.IGNORECASE) for query in keywords]
    fullQueries = re.compile("|".join([q.pattern for q in formatted_queries]), re.IGNORECASE)

    def process_pdf(path):  # Function for individual PDF processing
        print(f"Processing {path}")
        text = ""

        try:
            with pymupdf.open(path) as doc:
                text = "".join([page.get_text() for page in doc])
        except Exception as e:
            print(f"Error processing {path}: {e}")
            return
        print(f"end reading {path}")
        split_sentences = text.replace("\n", " ").split('.')
        sentences = [[] for _ in range(len(keywords))]

        # if bool(fullQueries.search(text)):
        #     for sentenceIndex, sentence in enumerate(split_sentences):
        #         for count, query in enumerate(formatted_queries):
        #             if bool(query.search(sentence)):
        #                 sentences[count].append(sentence.replace(",", "").replace(";", "").strip())
        search_sentences(split_sentences, formatted_queries, sentences)
        print(f"end search keyword {path}")

        filename = os.path.basename(path)
        ticker, year = extract_ticker_and_year(filename)

        # Locking mechanism for updating global variables
        with lock:
            wordPerFile[ticker + " " + year] = len([item for sublist in sentences for item in sublist])
            with open(sentencesFileName, "a", encoding='utf-8', errors='replace') as sentencesFile:
                for count, sentence in enumerate(sentences):
                    for sentencePart in sentence:
                        sentencesFile.write(f"{ticker},{year},"+ ","*count + f"{sentencePart}\n")

            with open(summaryFileName, "a", encoding='utf-8', errors='replace') as summaryFile:
                sentence_counts = [len(sentence_list) for sentence_list in sentences]
                summaryFile.write(f"{ticker},{year}," + ",".join(map(str, sentence_counts)) + "\n")

    # Use a thread pool to limit concurrent threads
    with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
        executor.map(process_pdf, paths)
    
    print("all pdf has been processed")

    return resultMap

@app.route('/start_word_count', methods=['POST'])
def start_word_count():
    data = request.json
    task_id = str(len(word_count_results) + 1)
    file_paths = data.get('file_paths', [])
    rawKeywords = data.get('keywords', [])
    task_status[task_id] = 'running'

    if "##import##" in rawKeywords:
        print("import prompt from import.txt")
        global importFileName
        with open(importFileName, "r", encoding="utf-8") as importFile:
            rawKeywords.extend(line.strip() for line in importFile)

    while "##import##" in rawKeywords:
        rawKeywords.remove("##import##")

    keywords = [s.replace("\n", " ").replace("\r", " ").rstrip() for s in rawKeywords]
    print(keywords)

    # Get the current date and time
    now = datetime.now()

    # Format the date and time as a string
    dateStr = now.strftime("%Y-%m-%d %H-%M-%S")

    global sentencesFileName
    global summaryFileName

    sentencesFileName = "sentences-" + dateStr + ".csv"
    summaryFileName = "summary-"+dateStr + ".csv"

    with open(sentencesFileName, "w") as sentencesFile:
        sentencesFile.write(f"Ticker,Year,{','.join(keywords)}\n")

    with open(summaryFileName, "w") as summaryFile:
        summaryFile.write(f"Ticker,Year,{','.join(keywords)}\n")

    executor.submit_stored(task_id, process_word_count, task_id, file_paths, keywords)
    return jsonify({'task_id': task_id, 'status': 'started'})

def process_word_count(task_id, file_paths, keywords):
    result = count(file_paths, keywords)
    word_count_results[task_id] = result
    task_status[task_id] = 'completed'

@app.route('/word_count_status/<task_id>', methods=['GET'])
def word_count_status(task_id):
    global resultMap
    status = task_status.get(task_id, 'unknown')
    result = jsonify({'status': status, 'result': wordPerFile})
    with lock:
        wordPerFile.clear()
    return result

if __name__ == '__main__':
    print("version 1.4.0")
    app.run(debug=False, port=5000)
