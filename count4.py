import tkinter as tk
from tkinter import messagebox
import math
import random

ROWS = 6
COLS = 7
PLAYER = 1
AI = 2
EMPTY = 0
WINDOW_LENGTH = 4
MAX_DEPTH = 4
CELL_SIZE = 80

def create_board():
    return [[0] * COLS for _ in range(ROWS)]

def drop_piece(board, row, col, piece):
    board[row][col] = piece

def is_valid_location(board, col):
    return board[0][col] == 0

def get_next_open_row(board, col):
    for r in range(ROWS-1, -1, -1):
        if board[r][col] == 0:
            return r

def winning_move(board, piece):
    # Horizontal
    for r in range(ROWS):
        for c in range(COLS-3):
            if all(board[r][c+i] == piece for i in range(4)):
                return True
    # Vertical
    for c in range(COLS):
        for r in range(ROWS-3):
            if all(board[r+i][c] == piece for i in range(4)):
                return True
    # Positive diagonals
    for r in range(ROWS-3):
        for c in range(COLS-3):
            if all(board[r+i][c+i] == piece for i in range(4)):
                return True
    # Negative diagonals
    for r in range(3, ROWS):
        for c in range(COLS-3):
            if all(board[r-i][c+i] == piece for i in range(4)):
                return True
    return False

def evaluate_window(window, piece):
    score = 0
    opp_piece = PLAYER if piece == AI else AI
    if window.count(piece) == 4:
        score += 100
    elif window.count(piece) == 3 and window.count(EMPTY) == 1:
        score += 5
    elif window.count(piece) == 2 and window.count(EMPTY) == 2:
        score += 2
    if window.count(opp_piece) == 3 and window.count(EMPTY) == 1:
        score -= 4
    return score

def score_position(board, piece):
    score = 0
    center_array = [board[r][COLS//2] for r in range(ROWS)]
    score += center_array.count(piece) * 3

    for r in range(ROWS):
        row_array = board[r]
        for c in range(COLS-3):
            score += evaluate_window(row_array[c:c+WINDOW_LENGTH], piece)

    for c in range(COLS):
        col_array = [board[r][c] for r in range(ROWS)]
        for r in range(ROWS-3):
            score += evaluate_window(col_array[r:r+WINDOW_LENGTH], piece)

    for r in range(ROWS-3):
        for c in range(COLS-3):
            window = [board[r+i][c+i] for i in range(WINDOW_LENGTH)]
            score += evaluate_window(window, piece)

    for r in range(ROWS-3):
        for c in range(COLS-3):
            window = [board[r+3-i][c+i] for i in range(WINDOW_LENGTH)]
            score += evaluate_window(window, piece)

    return score

def get_valid_locations(board):
    return [c for c in range(COLS) if is_valid_location(board, c)]

def is_terminal_node(board):
    return winning_move(board, PLAYER) or winning_move(board, AI) or len(get_valid_locations(board)) == 0

def minimax(board, depth, alpha, beta, maximizingPlayer):
    valid_locations = get_valid_locations(board)
    terminal = is_terminal_node(board)
    if depth == 0 or terminal:
        if terminal:
            if winning_move(board, AI):
                return (None, 1e10)
            elif winning_move(board, PLAYER):
                return (None, -1e10)
            else:
                return (None, 0)
        else:
            return (None, score_position(board, AI))

    if maximizingPlayer:
        value = -math.inf
        best_col = random.choice(valid_locations)
        for col in valid_locations:
            row = get_next_open_row(board, col)
            b_copy = [r[:] for r in board]
            drop_piece(b_copy, row, col, AI)
            new_score = minimax(b_copy, depth-1, alpha, beta, False)[1]
            if new_score > value:
                value = new_score
                best_col = col
            alpha = max(alpha, value)
            if alpha >= beta:
                break
        return best_col, value
    else:
        value = math.inf
        best_col = random.choice(valid_locations)
        for col in valid_locations:
            row = get_next_open_row(board, col)
            b_copy = [r[:] for r in board]
            drop_piece(b_copy, row, col, PLAYER)
            new_score = minimax(b_copy, depth-1, alpha, beta, True)[1]
            if new_score < value:
                value = new_score
                best_col = col
            beta = min(beta, value)
            if alpha >= beta:
                break
        return best_col, value

# ----------- GUI -----------
class ConnectFourGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Connect Four (Minimax AI)")
        self.board = create_board()
        self.turn = PLAYER

        self.canvas = tk.Canvas(root, width=COLS*CELL_SIZE, height=ROWS*CELL_SIZE, bg="blue")
        self.canvas.pack()
        self.canvas.bind("<Button-1>", self.human_move)

        self.draw_board()

    def draw_board(self):
        self.canvas.delete("all")
        for r in range(ROWS):
            for c in range(COLS):
                x1 = c * CELL_SIZE
                y1 = r * CELL_SIZE
                x2 = x1 + CELL_SIZE
                y2 = y1 + CELL_SIZE
                self.canvas.create_oval(x1+5, y1+5, x2-5, y2-5,
                    fill=self.get_color(self.board[r][c]), outline="black")

    def get_color(self, piece):
        if piece == PLAYER:
            return "red"
        elif piece == AI:
            return "yellow"
        return "white"

    def human_move(self, event):
        if self.turn != PLAYER: return
        col = event.x // CELL_SIZE
        if col < 0 or col >= COLS or not is_valid_location(self.board, col):
            return
        row = get_next_open_row(self.board, col)
        drop_piece(self.board, row, col, PLAYER)
        self.draw_board()

        if winning_move(self.board, PLAYER):
            self.end_game("You Win!")
            return

        if len(get_valid_locations(self.board)) == 0:
            self.end_game("Draw!")
            return

        self.turn = AI
        self.root.after(500, self.ai_move)

    def ai_move(self):
        col, _ = minimax(self.board, MAX_DEPTH, -math.inf, math.inf, True)
        if is_valid_location(self.board, col):
            row = get_next_open_row(self.board, col)
            drop_piece(self.board, row, col, AI)
        self.draw_board()

        if winning_move(self.board, AI):
            self.end_game("AI Wins!")
            return

        if len(get_valid_locations(self.board)) == 0:
            self.end_game("Draw!")
            return

        self.turn = PLAYER

    def end_game(self, msg):
        self.draw_board()
        messagebox.showinfo("Game Over", msg)
        self.root.destroy()

# ------------ Run ------------
root = tk.Tk()
app = ConnectFourGUI(root)
root.mainloop()
