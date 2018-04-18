"""
Clone of 2048 game.
"""

import poc_2048_gui
import random

# Directions, DO NOT MODIFY
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

# Offsets for computing tile indices in each direction.
# DO NOT MODIFY this dictionary.
OFFSETS = {UP: (1, 0),
           DOWN: (-1, 0),
           LEFT: (0, 1),
           RIGHT: (0, -1)}

def merge(line):
    """
    Helper function that merges a single row or column in 2048
    """
    nonzeros_removed = []
    result = []
    merged = False
    for number in line:
        if number != 0:
            nonzeros_removed.append(number)

    while len(nonzeros_removed) != len(line):
        nonzeros_removed.append(0)
        
    # Double sequental tiles if same value
    for number in range(0, len(nonzeros_removed) - 1):
        if nonzeros_removed[number] == nonzeros_removed[number + 1] and merged == False:
            result.append(nonzeros_removed[number] * 2)
            merged = True
        elif nonzeros_removed[number] != nonzeros_removed[number + 1] and merged == False:
            result.append(nonzeros_removed[number])
        elif merged == True:
            merged = False
    
    if nonzeros_removed[-1] != 0 and merged == False:
        result.append(nonzeros_removed[-1])

    while len(result) != len(nonzeros_removed):
        result.append(0)

    return result

class TwentyFortyEight:
    """
    Class to run the game logic.
    """

    def __init__(self, grid_height, grid_width):
        self._height=grid_height
        self._width=grid_width
        self._grid = []
        self.reset()
        
        self._initial = {
            UP : [[0,element] for element in range(self.get_grid_width())],
            DOWN : [[self.get_grid_height() - 1, element] for element in range(self.get_grid_width())],
            LEFT : [[element, 0] for element in range(self.get_grid_height())],
            RIGHT : [[element, self.get_grid_width() - 1] for element in range (self.get_grid_height())]
        }
        
        self._numsteps = {
            UP: self.get_grid_height(),DOWN: self.get_grid_height(),
            LEFT: self.get_grid_width(),RIGHT: self.get_grid_width(),
        }
        
    def reset(self):
        """
        Reset the game so the grid is empty except for two
        initial tiles.
        """
        # replace with your code
        self._grid = [[0 for dummy_col in range(self.get_grid_width())] for dummy_row in range(self.get_grid_height())]
        self.new_tile()
        self.new_tile()

    def __str__(self):
        """
        Return a string representation of the grid for debugging.
        """
        out = ""
        for number in range(0, self.get_grid_height()):
            out += str(number) + "\n"
        return out

    def get_grid_height(self):
        """
        Get the height of the board.
        """
        return self._height

    def get_grid_width(self):
        """
        Get the width of the board.
        """
        return self._width

    def move(self, direction):
        """
        Move all tiles in the given direction and add
        a new tile if any tiles moved.
        """
        initial_list = self._initial[direction]
        temporary_list = []
        
        before_move = str(self._grid)

        for element in initial_list:
            temporary_list.append(element)
            
            for index in range(1, self._numsteps[direction]):
                new_element=[element[0]+index*OFFSETS[direction][0],element[1]+index*OFFSETS[direction][1]]
                temporary_list.append(new_element)
            
            indices = []
            
            for index in temporary_list:
                indices.append(self.get_tile(index[0], index[1]))
            
            merged_list = merge(indices)
            
            for index_x, index_y in zip(merged_list, temporary_list):
                self.set_tile(index_y[0], index_y[1], index_x)
        
            temporary_list = []
        
        after_move = str(self._grid)
        
        if before_move != after_move:
            self.new_tile()
    
    
    def new_tile(self):
        """
        Create a new tile in a randomly selected empty
        square.  The tile should be 2 90% of the time and
        4 10% of the time.
        """
        remaining_zeros=[]
        for row in range(self._height):
            for col in range(self._width):
                if self._grid[row][col]==0:
                    remaining_zeros.append([row,col])
        if not remaining_zeros:
            print "There are no remaing zeros"
        else:
            random_tile=random.choice(remaining_zeros)
            weighted_choices = [(2, 9), (4, 1)]
            sample = [val for val, prob in weighted_choices for dummy_i in range(prob)]
            tile = random.choice(sample)
            self.set_tile(random_tile[0],random_tile[1], tile)

    def set_tile(self, row, col, value):
        """
        Set the tile at position row, col to have the given value.
        """
        self._grid[row][col]=value

    def get_tile(self, row, col):
        """
        Return the value of the tile at position row, col.
        """
        return self._grid[row][col]


poc_2048_gui.run_gui(TwentyFortyEight(4, 4))
