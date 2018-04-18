"""
Planner for Yahtzee
Simplifications:  only allow discard and roll, only score against upper level
"""

# Used to increase the timeout, if necessary
import codeskulptor
codeskulptor.set_timeout(20)

def gen_all_sequences(outcomes, length):
    """
    Iterative function that enumerates the set of all sequences of
    outcomes of given length.
    """
    
    answer_set = set([()])
    for dummy_idx in range(length):
        temp_set = set()
        for partial_sequence in answer_set:
            for item in outcomes:
                new_sequence = list(partial_sequence)
                new_sequence.append(item)
                temp_set.add(tuple(new_sequence))
        answer_set = temp_set
    return answer_set


def score(hand):
    """
    Compute the maximal score for a Yahtzee hand according to the
    upper section of the Yahtzee score card.

    hand: full yahtzee hand

    Returns an integer score 
    """
    num_list=[]
    max_dice=max(hand)
    for idx in range(1,max_dice+1):
        new_num=hand.count(idx)
        num_list.append(new_num*idx)
    max_score=max(num_list)
    return max_score


def expected_value(held_dice, num_die_sides, num_free_dice):
    """
    Compute the expected value based on held_dice given that there
    are num_free_dice to be rolled, each with num_die_sides.

    held_dice: dice that you will hold
    num_die_sides: number of sides on each die
    num_free_dice: number of dice to be rolled

    Returns a floating point expected value
    """
    
    outcomes=set()
    for idx in range(num_die_sides):
        outcomes.add(idx+1)
    #outcomes = set([1, 2, 3, 4, 5, 6])
    unsorted_set=gen_all_sequences(outcomes, num_free_dice)
    #sorted_list = [tuple(sorted(seq)) for seq in unsorted_set]
    full_list=[]
    for seq in unsorted_set:
        new_seq=seq+held_dice
        full_list.append(new_seq)
        
    full_set=set(full_list)
    value_list=[]
    for each in full_set:
        #print each
        new_value=score(each)
        value_list.append(new_value)
    exp_value=float(sum(value_list))/float(len(value_list))
    return exp_value


def gen_all_holds(hand):
    """
    Generate all possible choices of dice from hand to hold.
    hand: full yahtzee hand
    Returns a set of tuples, where each tuple is dice to hold
    """
    def gen_all_hold_recur(hand,_len):
        """
        The recursion function to 
        generate all possible choices of dice from hand to hold.
        hand: full yahtzee hand
        _len: length of list hand 
        
        Returns a set of tuples, where each tuple is dice to hold
        """
        if _len == 0:
            return set([()])
        
        _drop = hand[0]
        _hand = gen_all_hold_recur(hand[1:],_len-1)
        _set = set([()])
        for _item in _hand:
            _store = list(_item)
            _store.append(_drop)
            _set.add(tuple(sorted(_store)))
        _set.update(_hand)
        return _set
    return gen_all_hold_recur(hand,len(hand))



def strategy(hand, num_die_sides):
    """
    Compute the hold that maximizes the expected value when the
    discarded dice are rolled.

    hand: full yahtzee hand
    num_die_sides: number of sides on each die

    Returns a tuple where the first element is the expected score and
    the second element is a tuple of the dice to hold
    """
    sorted_set=gen_all_holds(hand)
    max_value=0.0
    for each in sorted_set:
        new_expvalue=expected_value(each, num_die_sides, len(hand)-len(each))
        if new_expvalue>max_value:
            max_value=new_expvalue
            max_hold=each
    return max_value,max_hold


def run_example():
    """
    Compute the dice to hold and expected score for an example hand
    """
    num_die_sides = 6
    hand = (1, 1, 1, 5, 6)
    hand_score, hold = strategy(hand, num_die_sides)
    print "Best strategy for hand", hand, "is to hold", hold, "with expected score", hand_score
    
    
#run_example()


#import poc_holds_testsuite
#poc_holds_testsuite.run_suite(gen_all_holds)
                                       
    
    
    



