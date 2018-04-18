/**
 * A Graduate represents a college graduate
 * @author Suzanne Balik
 */
public class Graduate {

    /** First name of graduate */
    private String name;
  
    /** Degree earned */ 
    private String degree;
  
    /** Graduation year */
    private int year;
  
    /**
     * Constructs and initializes a Graduate object.
     * @param name first name of graduate
     * @param degree degree
     * @param year graduation year
     * @throws NullPointerException if name or degree is null
     * @throws IllegalArgumentException if year is negative
     */
    public Graduate (String name, String degree, int year) {
        if (name == null) {
            throw new NullPointerException("name is null");
        }
        if (degree == null) {
            throw new NullPointerException("degree is null");
        }
        if (year < 0) {
            throw new IllegalArgumentException("year is negative");
        }
        this.name = name;
        this.degree = degree;
        this.year = year;
    }
 
    /**
     * Returns the name
     * @return the name
     */
    public String getName() {
        return name;
    } 
    
    /**
     * Returns the degree
     * @return the degree
     */
    public String getDegree() {
        return degree;
    } 
    
    /**
     * Returns the year
     * @return the year
     */
    public int getYear() {
        return year;
    }
}
  
  