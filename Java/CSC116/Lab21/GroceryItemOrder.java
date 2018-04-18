public class GroceryItemOrder {
    private String name;  
    private double pricePerUnit;  
    private int quantity;  

    public GroceryItemOrder(String name, int quantity, double pricePerUnit) {  

        this.name = name;  
        this.pricePerUnit = pricePerUnit;  
        this.quantity = quantity;  

    }  

    public double getCost() {  

        return (this.quantity * this.pricePerUnit);  
    }  

    public void setQuantity(int quantity) {  

        this.quantity = quantity;  

    } 
    
    /**
     * Returns a String representation of this GroceryItemOrder.
     * 
     * @return String representation of this GroceryItemOrder
     */
    public String toString() {
        return quantity + " " + name + " at " + pricePerUnit;
    }

    
    /**
     * Returns whether the given object is a GroceryItemOrder that refers to the same
     * name/quantity/pricePerUnit as this GroceryItemOrder.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-GroceryItemOrders
        if (o instanceof GroceryItemOrder) {
            GroceryItemOrder other = (GroceryItemOrder) o;
            return name.equals(other.name) && pricePerUnit == other.pricePerUnit && quantity == other.quantity;
        } else {
            return false;
        }
    } 

}  