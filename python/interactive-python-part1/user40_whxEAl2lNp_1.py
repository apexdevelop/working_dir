"""
Monte Carlo Tic-Tac-Toe Player
"""

import random
import poc_ttt_gui
import poc_ttt_provided as provided

# Constants for Monte Carlo simulator
# You may change the values of these constants as desired, but
#  do not change their names.
NTRIALS = 10         # Number of trials to run
SCORE_CURRENT = 1.0 # Score for squares played by the current player
SCORE_OTHER = 1.0   # Score for squares played by the other player
EMPTY = 1
PLAYERX = 2
PLAYERO = 3 
DRAW = 4

# Add your functions here.
def mc_trial(board,player):
    """
    play a game starting with the given player by making random moves, 
    alternating between players. The modified board will contain the 
    state of the game. 
    """
    while(board.check_win() == None): 
        empty=board.get_empty_squares()
        choice=random.choice(empty)
        board.move(choice[0], choice[1], player)
        player = provided.switch_player(player)

def mc_update_scores( scores, board, player): 
    """
    Function takes a grid of scores, a board from a completed game, and 
    which player the machine player is. Function should score the completed 
    board and update the scores grid. The function updates the scores grid directly.
    """
    winner=board.check_win()
    if winner==DRAW:
       pass
    else:
       for xpos in range(board.get_dim()):
           for ypos in range(board.get_dim()):
               position =board.square(xpos,ypos)
               if position==PLAYERX:
                  if winner==PLAYERX:
                     scores[xpos][ypos]+=SCORE_CURRENT
                  else:
                     scores[xpos][ypos]-=SCORE_CURRENT
               elif position == PLAYERO: #player o, or other
                  if winner == PLAYERO:
                    scores[xpos][ypos] += SCORE_OTHER
                  else:
                    scores[xpos][ypos] -= SCORE_OTHER
        
def get_best_move(board, scores):
    """
    Function takes a current board and scores. Function find all of the
    empty squares with the maximum score and randomly return one of them.
    The case where the board is full will not be tested.
    """
    empty_squares = board.get_empty_squares()
    if (empty_squares == []):
        return
    
    #max_value = max_score_in_2d_list ( scores, empty_squares )
    max_value=None
    for empty in empty_squares:
        if ( scores[empty[0]][empty[1]] >= max_value ):
            max_value=scores[empty[0]][empty[1]]
    max_list = []        
    for empty in empty_squares:
        if ( scores[empty[0]][empty[1]] == max_value ):
            max_list.append(empty)
    empty = random.choice (max_list)
    return empty
    
    
def mc_move(board, player, trials):
    """
    Function takes a current board, machine player, and the number of trials. 
    Function uses the Monte Carlo simulation to return a move for the machine
    player in the form of a tuple.
    """
    #temp_board = board.clone()
    scores = [[0 for dummy_row in range(0, board.get_dim())] for dummy_col in range(0, board.get_dim())]
    
    for _dummy_trails in range(trials):
        temp_board = board.clone()
        mc_trial( temp_board, player)
        mc_update_scores( scores, temp_board, player )	      

    move=get_best_move(board,scores)
    #    print scores,move
    return move        

# Test game with the console or the GUI.  Uncomment whichever 
# you prefer.  Both should be commented out when you submit 
# for testing to save time.

# provided.play_game(mc_move, NTRIALS, False)        
# poc_ttt_gui.run_gui(3, provided.PLAYERX, mc_move, NTRIALS, False)
