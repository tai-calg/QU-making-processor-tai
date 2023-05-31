"""
目的：
うまく動く.dsと動かない.dsがあった時に、うまくいった.dsの命令との差分をとって、正しく動かない命令を抽出するため。

使い方：
たとえば addと第一引数にいれれば、addが含まれる行を削除するスクリプトです。
remove_lines_with_word()は１度目の実行時の時のみ使用してください。output.txtを作成します。

２度目以降はremove_lines_with_word_wq()を使用してください。output.txtを上書きします。

分けている理由はremove_lines_with_word()でin,outのファイルを同じにすると不具合を起こしoutputが空になるためです。
    詳細：
    Pythonでファイルを開いて変更を加える場合、ソースファイルとターゲットファイルを同じにするとデータの損失のリスクがあります。
    そのため、一般的には以下のように一時ファイルを使用します。

    入力ファイルを読み込み、一時ファイルに変更を書き込む。
    入力ファイルと一時ファイルを適切に閉じる。
    一時ファイルを元の入力ファイルに名前を変えて上書きする。
"""

import re

def remove_lines_with_word(word, input_file, output_file):
    with open(input_file, "r") as in_file, open(output_file, "w") as out_file:
        for line in in_file:
            if not re.search(r'\b' + re.escape(word) + r'\b', line):
                out_file.write(line)

# 以下のように関数を呼び出すことができます
## remove_lines_with_word("addi", "qsort_test.ds", "output.txt")


# ーーーーー### 一単語/上書き ###ーーーーー #
import os
import re
import tempfile

def remove_lines_with_word_wq(word, input_file):
    with open(input_file, "r") as in_file, tempfile.NamedTemporaryFile(delete=False) as temp_file:
        for line in in_file:
            if not re.search(r'\b' + re.escape(word) + r'\b', line):
                temp_file.write(line.encode('utf-8'))  # encode string to bytes
        
    os.replace(temp_file.name, input_file)

# 以下のように関数を呼び出すことができます
## 
remove_lines_with_word_wq("addi", "dijkstra_epsilon.ds")



# ーーーーー### 複数単語/上書き ###ーーーーー #
# 複数の単語を削除する場合
def remove_lines_with_words_wq(words, input_file):
    if words is None:
        return
    with open(input_file, "r") as in_file, tempfile.NamedTemporaryFile(delete=False) as temp_file:
        for line in in_file:
            if all(not re.search(r'\b' + re.escape(word) + r'\b', line) for word in words):
                temp_file.write(line.encode('utf-8'))  # encode string to bytes
        
    os.replace(temp_file.name, input_file)

# 以下のように関数を呼び出すことができます
## remove_lines_with_words_wq["単語1", "単語2", "単語3"], "output.txt")

# all_instructions = []
hello_instructions = ['add', 'addi', 'ret', 'jal', 'j', 'lui', 'sw', 'lw', 'sb', 'lbu', 'mv', 'bnez', 'nop', 'li', '.2byte']

qsort_instructions = (hello_instructions.copy())
qsort_instructions.extend(["srli","srai","slli","blt","bge","bne","bltu","zext.b","sub","andi","beqz","bltz","bgeu"\
        ,"blez","beqz","or","jr","neg","bgtz","xor"])
print(qsort_instructions)
## remove_lines_with_words_wq(qsort_instructions, "dijkstra_epsilon.ds")



# ーーーーー### 複数単語/上書き/指定した単語のみ残す ###ーーーーー #
# 逆に、特定の単語を含む行のみを抽出する場合
def leave_lines_with_words_wq(words, input_file):
    with open(input_file, "r") as in_file, tempfile.NamedTemporaryFile(delete=False) as temp_file:
        for line in in_file:
            if any(re.search(r'\b' + re.escape(word) + r'\b', line) for word in words):
                temp_file.write(line.encode('utf-8'))  # encode string to bytes
        
    os.replace(temp_file.name, input_file)

leave_line = ["sp"]
## leave_lines_with_words_wq(leave_line, "sp_search.txt")



# ーーーーー### 複数単語/新規作成/指定した単語のみ残す ###ーーーーー #
def leave_lines_with_words_wq_io(words, input_file, output_file):
    with open(input_file, "r") as in_file, open(output_file, "w") as out_file:
        for line in in_file:
            if any(re.search(r'\b' + re.escape(word) + r'\b', line) for word in words):
                out_file.write(line)

# 以下のように関数を呼び出すことができます
## leave_lines_with_words_wq_io(leave_line, "input.txt", "output.txt")
