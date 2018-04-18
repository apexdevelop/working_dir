# Mystery computation in Python
# Takes input n and computes output named result

import simplegui

# global state

iteration = 0
list_1=[];
# helper functions

def init(start):
    """Initializes n."""
    global result
    result = start
    print "Input is", result
    global list_1
    list_1.append(result)
    
    
def get_next(current):
    """???  Part of mystery computation."""
    remainder=current%2
    if remainder==0:
       current=current/2
    else:
       current=current*3+1
    return current

# timer callback

def update():
    """???  Part of mystery computation."""
    global iteration, result,list_1
    iteration += 1
    # Stop iterating after max_iterations
    if result== 1:
        timer.stop()
        print "Output is", result
        print "Max is",max(list_1)
    else:
        result = get_next(result)
        print result
        list_1.append(result)

# register event handlers

timer = simplegui.create_timer(1, update)

# start program
init(217)
timer.start()
