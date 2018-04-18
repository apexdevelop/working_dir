/**
 * Bread with type and calories
 * @author Yan Chen
 */
public class Bread {
    private String type;
    private int calories;
    
    
    /**
     * Constructs a new Bread to represent the specified type/calories.
     * 
     * @param type given type
     * @param calories given calories
     */
    public Bread(String type, int calories) {
        this.type = type;
        this.calories = calories;
    }
    
    /**
     * Returns this Bread's type.
     * 
     * @return type of this
     */
    public String getType() {
        return type;
    }
    
    /**
     * Returns this Bread's calories.
     * 
     * @return calories of this
     */
    public int getCalories() {
        return calories;
    }

    /**
     * Returns a String representation of this Bread.
     * 
     * @return String representation of this Bread
     */
    public String toString() {
        return type + ", " + calories;
    }

    
    /**
     * Returns whether the given object is a Bread that refers to the same
     * type/bread as this Bread.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-Breads
        if (o instanceof Bread) {
            Bread other = (Bread) o;
            return type.equals(other.type) && calories == other.calories;
        } else {
            return false;
        }
    }
}