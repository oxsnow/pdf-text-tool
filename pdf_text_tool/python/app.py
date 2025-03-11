from flask import Flask, request, jsonify
from flask_executor import Executor
from collections import Counter
import os
import PyPDF2

app = Flask(__name__)
executor = Executor(app)

word_count_results = {}
task_status = {}
resultMap = {}

def count(paths, keywords):
    """
    Reads each PDF from the list of paths, extracts the text,
    splits the text into sentences, and for each sentence that contains 
    any of the provided keywords (case-insensitive), it records that sentence.
    The results are stored in the global variable `resultMap` with the file's basename as the key.
    
    :param paths: List of file paths to PDF files.
    :param keywords: List of keywords to look for in the text.
    :return: The updated resultMap.
    """
    global resultMap
    # Optionally clear the global resultMap at the beginning.
    resultMap.clear()
    
    for path in paths:
        print(f"processing {path}")
        text = ""
        # Extract text from PDF safely.
        try:
            with open(path, "rb") as f:
                reader = PyPDF2.PdfReader(f)
                # Iterate over all the pages in the PDF.
                for page in reader.pages:
                    page_text = page.extract_text()
                    if page_text:
                        text += page_text + " "
        except Exception as e:
            # In case the file can't be read or processed.
            text = ""
            print(f"Error processing {path}: {e}")

        # Replace newlines with spaces and split the text into sentences by period.
        split_sentences = text.replace("\n", " ").split('.')
        sentences = []

        # Check each sentence for any of the keywords (case-insensitive).
        for sentence in split_sentences:
            for keyword in keywords:
                if keyword.lower() in sentence.lower():
                    sentences.append(sentence.strip())
                    # If a match is found, move to the next sentence
                    break

        # Use the file's basename as the dictionary key.
        filename = os.path.basename(path)
        resultMap[filename] = sentences

    return resultMap

@app.route('/start_word_count', methods=['POST'])
def start_word_count():
    data = request.json
    task_id = str(len(word_count_results) + 1)
    file_paths = data.get('file_paths', [])
    keywords = data.get('keywords', [])
    task_status[task_id] = 'running'
    executor.submit_stored(task_id, process_word_count, task_id, file_paths, keywords)
    return jsonify({'task_id': task_id, 'status': 'started'})

def process_word_count(task_id, file_paths, keywords):
    result = count(file_paths, keywords)
    word_count_results[task_id] = result
    task_status[task_id] = 'completed'

@app.route('/word_count_status/<task_id>', methods=['GET'])
def word_count_status(task_id):
    status = task_status.get(task_id, 'unknown')
    return jsonify({'status': status, 'result': resultMap})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
