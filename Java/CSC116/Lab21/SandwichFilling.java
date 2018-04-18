/**
 * SandwichFilling with type and calories
 * @author Yan Chen
 */
public class SandwichFilling {
    private String type;
    private int calories;
    
    
    /**
     * Constructs a new SandwichFilling to represent the specified type/calories.
     * 
     * @param type given type
     * @param calories given calories
     */
    public SandwichFilling(String type, int calories) {
        this.type = type;
        this.calories = calories;
    }
    
    /**
     * Returns this SandwichFilling's type.
     * 
     * @return type of this
     */
    public String getType() {
        return type;
    }
    
    /**
     * Returns this SandwichFilling's calories.
     * 
     * @return calories of this
     */
    public int getCalories() {
        return calories;
    }

    /**
     * Returns a String representation of this SandwichFilling.
     * 
     * @return String representation of this SandwichFilling
     */
    public String toString() {
        return type + ", " + calories;
    }

    
    /**
     * Returns whether the given object is a SandwichFilling that refers to the same
     * type/calories as this SandwichFilling.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-SandwichFillings
        if (o instanceof SandwichFilling) {
            SandwichFilling other = (SandwichFilling) o;
            return type.equals(other.type) && calories == other.calories;
        } else {
            return false;
        }
    }
}