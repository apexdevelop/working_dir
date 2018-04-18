public class GroceryList{
	//Defining variables 
	int totalItems = 0;
	double totalCost = 0.00;
	GroceryItemOrder[] groceryList;
	static final int maxItems = 10; //The max amount of items in the list is 10.
	
	
	public GroceryList(){
		groceryList = new GroceryItemOrder[maxItems]; //Instantiating grocery list
	} 
	
	public void add(GroceryItemOrder item){
		//If the totalItems are less than the max amount of items, add the item to the list.
		if (totalItems < maxItems){
			groceryList[this.totalItems] = item;
			++totalItems;
		}
		//If the list is full, say so.
		else{
			System.out.println("Grocery List is full.");
		}
		
	}
	
	public double getTotalCost(){
		//For every item in the grocery list, compute its cost and add it to the totalCost
		for ( int counter = 0; counter < this.totalItems; ++counter ){
			totalCost = totalCost + groceryList[counter].getCost();  
		}
		
		return totalCost;
	}
	
	/**
     * Returns a String representation of this GroceryList.
     * 
     * @return String representation of this GroceryList
     */
    public String toString() {
        String tempStr="";
        for (int i =0;i<totalItems;i++){
            tempStr=tempStr+groceryList[i].toString()+"/";
        }
        return tempStr;
    }

    
    /**
     * Returns whether the given object is a GroceryList that refers to the same
     * name/quantity/pricePerUnit as this GroceryList.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-GroceryItemOrders
        if (o instanceof GroceryList) {
            GroceryList other = (GroceryList) o;
            if (totalItems == other.totalItems && totalCost == other.totalCost) {
                for (int i =0;i<totalItems;i++){
                    if (groceryList[i]!=other.groceryList[i]) {
                        return false;
                    }
                }
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    } 
}