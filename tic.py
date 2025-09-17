import math

# A simple text-based Tic-Tac-Toe game with an unbeatable AI using Minimax
# with Alpha-Beta Pruning.

# Constants for players
HUMAN = 'X'
AI = 'O'
EMPTY = ' '

def print_board(board):
    """
    Prints the Tic-Tac-Toe board to the console.
    """
    print('-------------')
    for i in range(3):
        print(f'| {board[i*3]} | {board[i*3+1]} | {board[i*3+2]} |')
        print('-------------')

def get_empty_cells(board):
    """
    Returns a list of indices of empty cells on the board.
    """
    return [i for i, cell in enumerate(board) if cell == EMPTY]

def check_winner(board, player):
    """
    Checks if the given player has won the game.
    """
    # Winning combinations (rows, columns, diagonals)
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

def heuristic(board):
    """
    Evaluates the board from the AI's perspective.
    Positive values are good for AI, negative for Human.
    """
    score = 0
    win_conditions = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]
    
    for line in win_conditions:
        line_values = [board[i] for i in line]
        ai_count = line_values.count(AI)
        human_count = line_values.count(HUMAN)
        
        if ai_count > 0 and human_count == 0:
            if ai_count == 2:
                score += 10
            else:
                score += 1
        elif human_count > 0 and ai_count == 0:
            if human_count == 2:
                score -= 10
            else:
                score -= 1
                
    return score

def minimax_alpha_beta(board, depth, is_maximizing, alpha, beta):
    """
    The Minimax algorithm with Alpha-Beta pruning.
    """
    # Check for terminal states
    if check_winner(board, AI):
        return 1
    if check_winner(board, HUMAN):
        return -1
    if is_board_full(board):
        return 0

    if is_maximizing:
        best_score = -math.inf
        for cell_index in get_empty_cells(board):
            board[cell_index] = AI
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
            board[cell_index] = HUMAN
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
        board[cell_index] = AI
        score = minimax_alpha_beta(board, 0, False, -math.inf, math.inf)
        board[cell_index] = EMPTY
        
        if score > best_score:
            best_score = score
            best_move = cell_index
            
    return best_move

def main():
    """
    The main game loop.
    """
    board = [EMPTY] * 9
    print("Welcome to Tic-Tac-Toe!")
    print("You are 'X', the AI is 'O'.")
    print_board(board)
    
    current_player = HUMAN
    
    while True:
        if current_player == HUMAN:
            try:
                move = int(input("Enter your move (1-9): ")) - 1
                if 0 <= move <= 8 and board[move] == EMPTY:
                    board[move] = HUMAN
                    current_player = AI
                else:
                    print("Invalid move. Please try again.")
                    continue
            except ValueError:
                print("Invalid input. Please enter a number.")
                continue
        else:
            print("AI is making a move...")
            move = find_best_move(board)
            if move != -1:
                board[move] = AI
                current_player = HUMAN
        
        print_board(board)
        
        if check_winner(board, HUMAN):
            print("Congratulations! You win!")
            break
        elif check_winner(board, AI):
            print("The AI wins!")
            break
        elif is_board_full(board):
            print("It's a draw!")
            break

if __name__ == "__main__":
    main()
