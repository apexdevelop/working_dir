/**
 * Sandwich with bread and sandwichfillings
 * @author Yan Chen
 */
public class Sandwich {
    private Bread bread;
    private SandwichFilling filling;
    
    
    /**
     * Constructs a new Sandwich to represent the specified bread/filling.
     * 
     * @param bread given bread
     * @param filling given filling
     */
    public Sandwich(Bread bread, SandwichFilling filling) {
        this.bread = bread;
        this.filling = filling;
    }
    
    /**
     * Returns this Sandwich's bread.
     * 
     * @return bread of this
     */
    public Bread getBread() {
        return bread;
    }
    
    /**
     * Returns this Sandwich's filling.
     * 
     * @return filling of this
     */
    public SandwichFilling getFilling() {
        return filling;
    }

    /**
     * Returns a String representation of this Sandwich.
     * 
     * @return String representation of this Sandwich
     */
    public String toString() {
        return bread.toString() + "/" + filling.toString();
    }

    
    /**
     * Returns whether the given object is a Sandwich that refers to the same
     * bread/filling as this Sandwich.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-Sandwichs
        if (o instanceof Sandwich) {
            Sandwich other = (Sandwich) o;
            return bread.equals(other.bread) && filling.equals(other.filling);
        } else {
            return false;
        }
    }
    
    /**
     * Returns total calories based on bread and filling
     * @param bread
     * @param filling
     * @return total calories based on bread and filling
     */
    public int totalCalories() {
        int calories = 2* bread.getCalories() + filling.getCalories();
        return calories;

    }
}