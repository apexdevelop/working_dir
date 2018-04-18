"""
Cookie Clicker Simulator
"""

import simpleplot
import math

# Used to increase the timeout, if necessary
import codeskulptor
codeskulptor.set_timeout(20)

import poc_clicker_provided as provided

# Constants
SIM_TIME = 10000000000.0 

class ClickerState:
    """
    Simple class to keep track of the game state.
    """
    
    def __init__(self):
        self._total_cookies=0.0
        self._current_cookies=0.0
        self._current_time=0.0
        self._cps=1.0
        self._history=[(0.0, None, 0.0, 0.0)]
        
    def __str__(self):
        """
        Return human readable state
        """
        return ("Total cookies generated: " + str(self._total_cookies) + "\n" +
               "Current cookies: " + str(self._current_cookies) + "\n" + 
               "Current time: " + str(self._current_time) + "\n" + 
               "CPS: " + str(self._cps) + "\n") 
        
    def get_cookies(self):
        """
        Return current number of cookies 
        (not total number of cookies)
        
        Should return a float
        """
        return self._current_cookies
    
    def get_cps(self):
        """
        Get current CPS

        Should return a float
        """
        return self._cps
    
    def get_time(self):
        """
        Get current time

        Should return a float
        """
        return self._current_time
    
    def get_history(self):
        """
        Return history list

        History list should be a list of tuples of the form:
        (time, item, cost of item, total cookies)

        For example: [(0.0, None, 0.0, 0.0)]

        Should return a copy of any internal data structures,
        so that they will not be modified outside of the class.
        """
        return list(self._history)

    def time_until(self, cookies):
        """
        Return time until you have the given number of cookies
        (could be 0.0 if you already have enough cookies)

        Should return a float with no fractional part
        """
        if self._current_cookies > cookies:
            return 0.0
        else:
            return math.ceil((cookies - self._current_cookies) / self._cps)
    
    def wait(self, time):
        """
        Wait for given amount of time and update state

        Should do nothing if time <= 0.0
        """
        if time > 0:
            self._current_time += time
            self._current_cookies += (time*self._cps)
            self._total_cookies += (time*self._cps)          
        else:
            return 
    
    def buy_item(self, item_name, cost, additional_cps):
        """
        Buy an item and update state

        Should do nothing if you cannot afford the item
        """
        if self._current_cookies >= cost:
            self._current_cookies -= cost
            self._cps += additional_cps
            self._history.append((self._current_time, item_name, cost, self._total_cookies))
   
    
def simulate_clicker(build_info, duration, strategy):
    """
    Function to run a Cookie Clicker game for the given
    duration with the given strategy.  Returns a ClickerState
    object corresponding to the final state of the game.
    """

    # Create a clone for build info
    build_info_clone = build_info.clone()
    
    # Create a new ClickerState object
    clicker_s = ClickerState()
    
    while clicker_s.get_time()<=duration:
        item_to_buy=strategy(clicker_s.get_cookies(),clicker_s.get_cps(),clicker_s.get_history(),duration-clicker_s.get_time(),build_info_clone)
    
    # Break the loop if the item is None
        if item_to_buy is None:
            break
    # Determine how much time must elapse until it is possible to purchase the item. 
        elapsed = clicker_s.time_until(build_info_clone.get_cost(item_to_buy))
    
    # If you would have to wait past the duration of the simulation to purchase the item, 
    # you should end the simulation.
        if clicker_s.get_time() + elapsed > duration:
            break
    # Wait until that time
        clicker_s.wait(elapsed)
    
    # Buy the item
        clicker_s.buy_item(item_to_buy, build_info_clone.get_cost(item_to_buy), build_info_clone.get_cps(item_to_buy))
    
    # Update build information
        build_info_clone.update_item(item_to_buy)
        
    # If exited the loop, wait until the end of the simulation
    clicker_s.wait(duration - clicker_s.get_time())  
    
    return clicker_s


def strategy_cursor_broken(cookies, cps, history, time_left, build_info):
    """
    Always pick Cursor!

    Note that this simplistic (and broken) strategy does not properly
    check whether it can actually buy a Cursor in the time left.  Your
    simulate_clicker function must be able to deal with such broken
    strategies.  Further, your strategy functions must correctly check
    if you can buy the item in the time left and return None if you
    can't.
    """
    return "Cursor"

def strategy_none(cookies, cps, history, time_left, build_info):
    """
    Always return None

    This is a pointless strategy that will never buy anything, but
    that you can use to help debug your simulate_clicker function.
    """
    return None

def strategy_cheap(cookies, cps, history, time_left, build_info):
    """
    Always buy the cheapest item you can afford in the time left.
    """
    # Get the items list
    item_list = build_info.build_items()
    
    # Get the minimal cost item in list and its cost
    minval = float("inf")
    minidx = None
    for idx in range(len(item_list)):
        if build_info.get_cost(item_list[idx]) < minval:
            minval = build_info.get_cost(item_list[idx])
            minidx = idx
    
    # Minimum cost item in format [item_name, cost]
    min_cost_item = (item_list[minidx], build_info.get_cost(item_list[minidx]))
    
    # Return the object if I can buy it or None to exit
    if min_cost_item[1] <= (time_left * cps + cookies):
        return min_cost_item[0]
    else:
        return None

def strategy_expensive(cookies, cps, history, time_left, build_info):
    """
    Always buy the most expensive item you can afford in the time left.
    """
    # Get the items list
    item_strings = build_info.build_items()
    
    # Get the item and their costs 
    item_list = []
    for item in item_strings:
        item_list.append((build_info.get_cost(item), item))
    
    # Sort the list in reverse in terms of item cost
    item_list.sort(reverse=True)
    
    # Return the most expensive item for the time that's left   
    for item in item_list:
        if item[0] <= (time_left * cps + cookies):
            return item[1]      
    return None

def strategy_best(cookies, cps, history, time_left, build_info):
    """
    The best strategy that you are able to implement.
    """
    pricelist = {}  
    funding = cookies + cps * time_left  
    for item in build_info.build_items():  
        if build_info.get_cost(item) <= funding:  
            pricelist[build_info.get_cps(item)/build_info.get_cost(item)] = item  
    if len(pricelist) > 0:  
        return pricelist[max(pricelist)]  
    elif len(pricelist) == 0:   
        return None  
        
def run_strategy(strategy_name, time, strategy):
    """
    Run a simulation for the given time with one strategy.
    """
    state = simulate_clicker(provided.BuildInfo(), time, strategy)
    print strategy_name, ":", state

    # Plot total cookies over time

    # Uncomment out the lines below to see a plot of total cookies vs. time
    # Be sure to allow popups, if you do want to see it

    # history = state.get_history()
    # history = [(item[0], item[3]) for item in history]
    # simpleplot.plot_lines(strategy_name, 1000, 400, 'Time', 'Total Cookies', [history], True)

def run():
    """
    Run the simulator.
    """    
    #run_strategy("Cursor", SIM_TIME, strategy_cursor_broken)

    # Add calls to run_strategy to run additional strategies
    # run_strategy("Cheap", SIM_TIME, strategy_cheap)
    # run_strategy("Expensive", SIM_TIME, strategy_expensive)
    run_strategy("Best", SIM_TIME, strategy_best)
    
run()
    

