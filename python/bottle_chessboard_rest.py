from bottle import route, request, response, template, run
import re
import numpy as np

#"".join(["".join(["x" if r == 10 else "o" for c in range(50) ]) + "$" for r in range(20)])
#http://localhost:8080/game/oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$oooooooooooooooooooooooooooooooooooooooooooooooooo$

@route('/game/<board:re:[ox$]*>')
def display_forum(board):
    split = re.split("\$", board)
    max_cols = max([len(row) for row in split])
    board = np.array([[0 if cell == "o" else 1 for cell in cells] for cells in [row.ljust(max_cols, "o") for row in split]])
    chess_board = chess_board = "".join(["<tr>" + "".join(["".join(["<td class=","dark" if b==0 else "light","></td>"]) for b in a]) + "</tr>" for a in board])
    html = """
<!DOCTYPE html>
<html>
    <head>
        <title></title>
        <meta charset="UTF-8">
        <style>
            .chess-board { border-spacing: 0; border-collapse: collapse; }
            .chess-board th { padding: .5em; }
            .chess-board td { border: 1px solid; width: 1em; height: 1em; }
            .chess-board .light { background: #eee; }
            .chess-board .dark { background: #000; }
        </style>
    </head>
    <body>
        <table class="chess-board">
            <tbody>""" + chess_board + """
            </tbody>
        </table>
    </body>
</html>    
    """
    return template(html)
    #return template('Forum ID: {{id}} (page {{page}})', id=forum_id, page=page)

run(host='localhost', port=8080)
