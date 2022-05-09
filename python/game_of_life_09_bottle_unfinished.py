from bottle import route, request, response, template, run
import re
import numpy as np

@route('/game/<board:re:[ox$]*>')
def display_forum(board):
    split = re.split("\$", board)
    max_cols = max([len(row) for row in split])
    board = np.array([[0 if cell == "o" else 1 for cell in cells] for cells in [row.ljust(max_cols, "o") for row in split]])
    html = ""
    for x in np.ndindex(board.shape):
        html += str(board[x])
    forum_id = request.query.id
    print(board)
    page = request.query.page or '1'
    return template(html)
    #return template('Forum ID: {{id}} (page {{page}})', id=forum_id, page=page)

run(host='localhost', port=8080)
