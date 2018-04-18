"""
Merge function for 2048 game.
"""
def merge(line):
    """
    Function that merges a single row or column in 2048.
    """

    def slid(line):
        """
        Function that slides numbers to left
        """
        lst_slid=[0]*len(line)
        count_slid=0
        for idx in range(len(line)):
            if line[idx]<>0:
               lst_slid[count_slid]=line[idx]
               count_slid+=1
        return lst_slid
    
    lst_slid=slid(line)

    is_merge=[0]*len(line)
    def replace(lst_slid,is_merge):
        """
        Function that replaces two identical numbers
        """
        lst_replace=[0]*len(line)
        count_replace=0
        idx=0
        while idx<len(line)-1:          
            if lst_slid[idx]==lst_slid[idx+1] and count_replace==0 and is_merge[idx]==0 and is_merge[idx+1]==0 and lst_slid[idx]>0:               
                  lst_replace[idx]=2*lst_slid[idx]
                  lst_replace[idx+1]=0
                  count_replace+=1
                  is_merge[idx]=1
                  idx=idx+2                  
            else:
                  lst_replace[idx]=lst_slid[idx]
                  idx=idx+1
        if is_merge[len(line)-2]<>1:
            lst_replace[len(line)-1]=lst_slid[len(line)-1]
        return lst_replace,is_merge
    
    lst_replace,is_merge=replace(lst_slid,is_merge)
    
    def loop(lst_replace,is_merge):
        """
        Function that repeats sliding and replacing
        """
        lst_slid=slid(lst_replace)
        lst_replace,is_merge=replace(lst_slid,is_merge)
        #for idx in range(len(line)):
        while lst_slid<>lst_replace:
            lst_slid=slid(lst_replace)
            lst_replace,is_merge=replace(lst_slid,is_merge)
        return lst_replace,is_merge
    
    result,is_merge=loop(lst_replace,is_merge)
    
    #return result,is_merge
    return result
    
#line=[2,2,2,2,2,2]
#line=[8,2,2]
#result,is_merge=merge(line)
#print result, is_merge