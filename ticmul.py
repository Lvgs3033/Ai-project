import math
import tkinter as tk
from tkinter import messagebox
import time

# A graphical Tic-Tac-Toe game with an unbeatable AI using Minimax
# with Alpha-Beta Pruning.

# Constants for players and board state
HUMAN_PLAYER_1 = 'X'
HUMAN_PLAYER_2 = 'O'
AI_PLAYER = 'O'
EMPTY = ' '

class TicTacToe:
    def __init__(self, master):
        self.master = master
        master.title("Tic-Tac-Toe")
        master.configure(bg="#f0f0f0")

        self.board = [EMPTY] * 9
        self.current_player = None
        self.is_game_active = False
        self.game_mode = None

        self.status_label = tk.Label(master, text="", font=('Helvetica', 18, 'bold'), bg="#f0f0f0", fg="#333")
        self.status_label.grid(row=0, column=0, columnspan=3, pady=10)

        self.buttons = []
        self.board_frame = tk.Frame(self.master)
        self.mode_frame = tk.Frame(self.master)
        
        self.show_mode_selection()

    def show_mode_selection(self):
        """
        Displays buttons for selecting the game mode.
        """
        self.board_frame.grid_forget()
        self.status_label.config(text="Select Game Mode")
        
        self.mode_frame.grid(row=1, column=0, columnspan=3, padx=10, pady=10)

        single_player_button = tk.Button(self.mode_frame, text="Single Player (vs AI)", font=('Helvetica', 14, 'bold'),
                                         command=lambda: self.start_game("single_player"),
                                         bg="#4CAF50", fg="white", activebackground="#45a049",
                                         bd=0, relief="flat", padx=10, pady=5)
        single_player_button.grid(row=0, column=0, padx=5, pady=5)

        multiplayer_button = tk.Button(self.mode_frame, text="Multiplayer (vs Human)", font=('Helvetica', 14, 'bold'),
                                       command=lambda: self.start_game("multiplayer"),
                                       bg="#2196F3", fg="white", activebackground="#1e88e5",
                                       bd=0, relief="flat", padx=10, pady=5)
        multiplayer_button.grid(row=0, column=1, padx=5, pady=5)
    
    def start_game(self, mode):
        """
        Initializes and starts a new game with the selected mode.
        """
        self.game_mode = mode
        self.mode_frame.grid_forget()
        self.board_frame = tk.Frame(self.master, bg="#333", bd=5, relief="raised")
        self.board_frame.grid(row=1, column=0, columnspan=3, padx=10, pady=10)
        self.buttons = []
        self.create_board_gui()
        self.reset_game()
        
        self.reset_button = tk.Button(self.master, text="Restart Game", font=('Helvetica', 14, 'bold'), command=self.reset_game,
                                      bg="#4CAF50", fg="white", activebackground="#45a049",
                                      bd=0, relief="flat", padx=10, pady=5)
        self.reset_button.grid(row=4, column=0, columnspan=3, pady=10)


    def create_board_gui(self):
        """
        Creates the 3x3 grid of buttons for the game board.
        """
        for i in range(9):
            button = tk.Button(self.board_frame, text="", font=('Helvetica', 36, 'bold'), width=4, height=2,
                               bg="#e0e0e0", fg="#333", activebackground="#d0d0d0", relief="flat",
                               command=lambda i=i: self.handle_click(i))
            button.grid(row=i // 3, column=i % 3, padx=5, pady=5)
            self.buttons.append(button)

    def handle_click(self, index):
        """
        Handles a button click. The logic depends on the game mode.
        """
        if self.board[index] == EMPTY and self.is_game_active:
            self.board[index] = self.current_player
            self.buttons[index].config(text=self.current_player, fg="#ff0000" if self.current_player == HUMAN_PLAYER_1 else "#0000ff")
            self.check_game_over()
            
            if self.is_game_active:
                if self.game_mode == "single_player":
                    self.current_player = AI_PLAYER
                    self.status_label.config(text="AI's turn (O)")
                    self.master.after(500, self.ai_move)
                else:
                    self.current_player = HUMAN_PLAYER_2 if self.current_player == HUMAN_PLAYER_1 else HUMAN_PLAYER_1
                    self.status_label.config(text=f"Player {self.current_player}'s turn")

    def ai_move(self):
        """
        Finds and executes the best move for the AI.
        """
        if self.is_game_active:
            move = find_best_move(self.board)
            if move != -1:
                self.board[move] = AI_PLAYER
                self.buttons[move].config(text=AI_PLAYER, fg="#0000ff")
            
            self.check_game_over()
            if self.is_game_active:
                self.current_player = HUMAN_PLAYER_1
                self.status_label.config(text="Your turn (X)")

    def check_game_over(self):
        """
        Checks for a win, a draw, or continues the game.
        """
        if check_winner(self.board, self.current_player):
            if self.game_mode == "single_player":
                status_text = "You win!" if self.current_player == HUMAN_PLAYER_1 else "The AI wins!"
                messagebox.showinfo("Game Over", status_text)
            else:
                status_text = f"Player {self.current_player} wins!"
                messagebox.showinfo("Game Over", status_text)
            
            self.status_label.config(text=status_text)
            self.is_game_active = False
            return
            
        elif is_board_full(self.board):
            self.status_label.config(text="It's a draw!")
            self.is_game_active = False
            messagebox.showinfo("Game Over", "It's a draw!")
            return

    def reset_game(self):
        """
        Resets the game state and board for a new game.
        """
        self.board = [EMPTY] * 9
        self.is_game_active = True
        self.current_player = HUMAN_PLAYER_1

        for i in range(9):
            self.buttons[i].config(text="", fg="#333")
            
        self.status_label.config(text=f"Player {self.current_player}'s turn")
        if self.game_mode == "single_player":
            self.status_label.config(text="Your turn (X)")

def get_empty_cells(board):
    """
    Returns a list of indices of empty cells on the board.
    """
    return [i for i, cell in enumerate(board) if cell == EMPTY]

def check_winner(board, player):
    """
    Checks if the given player has won the game.
    """
    win_conditions = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]
    
    for condition in win_conditions:
        if board[condition[0]] == player and \
           board[condition[1]] == player and \
           board[condition[2]] == player:
            return True
    return False

def is_board_full(board):
    """
    Checks if the board is completely filled (a draw).
    """
    return EMPTY not in board

def minimax_alpha_beta(board, depth, is_maximizing, alpha, beta):
    """
    The Minimax algorithm with Alpha-Beta pruning.
    
    Returns:
        An integer representing the score of the board.
    """
    if check_winner(board, AI_PLAYER):
        return 1
    if check_winner(board, HUMAN_PLAYER_1):
        return -1
    if is_board_full(board):
        return 0

    if is_maximizing:
        best_score = -math.inf
        for cell_index in get_empty_cells(board):
            board[cell_index] = AI_PLAYER
            score = minimax_alpha_beta(board, depth + 1, False, alpha, beta)
            board[cell_index] = EMPTY
            best_score = max(best_score, score)
            alpha = max(alpha, best_score)
            if beta <= alpha:
                break
        return best_score
    else:
        best_score = math.inf
        for cell_index in get_empty_cells(board):
            board[cell_index] = HUMAN_PLAYER_1
            score = minimax_alpha_beta(board, depth + 1, True, alpha, beta)
            board[cell_index] = EMPTY
            best_score = min(best_score, score)
            beta = min(beta, best_score)
            if beta <= alpha:
                break
        return best_score

def find_best_move(board):
    """
    Finds the best move for the AI using the minimax_alpha_beta function.
    """
    best_score = -math.inf
    best_move = -1
    
    for cell_index in get_empty_cells(board):
        board[cell_index] = AI_PLAYER
        score = minimax_alpha_beta(board, 0, False, -math.inf, math.inf)
        board[cell_index] = EMPTY
        
        if score > best_score:
            best_score = score
            best_move = cell_index
            
    return best_move

if __name__ == "__main__":
    root = tk.Tk()
    game = TicTacToe(root)
    root.mainloop()
