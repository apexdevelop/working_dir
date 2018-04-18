/**
 * FitnessTracker
 * @author Yan Chen
 */
public class FitnessTracker {
    private String activity;
    private int minutes;
    private Date date;
    
    /**
     * Constructs a default FitnessTracker.
     */
    public FitnessTracker() {
        //this("running", 0, new Date(2016,1,1));
        this("running", 0, new Date(new Date().getYear(),1,1));
    }
    
    /**
     * Constructs a new FitnessTracker to represent the specified activity/minutes/date.
     * 
     * @param activity given activity
     * @param minutes given minutes
     * @param date given date
     */
    public FitnessTracker(String activity, int minutes, Date date) {
        this.activity = activity;
        this.minutes = minutes;
        this.date = date;
    }
    
    /**
     * Returns this FitnessTracker's activity.
     * 
     * @return activity of this
     */
    public String getActivity() {
        return activity;
    }
    
    /**
     * Returns this FitnessTracker's minutes.
     * 
     * @return minutes of this
     */
    public int getMinutes() {
        return minutes;
    }
    
    /**
     * Returns this FitnessTracker's date.
     * 
     * @return date of this
     */
    public Date getDate() {
        return date;
    }
    
    
    /**
     * Returns a String representation of this FitnessTracker.
     * 
     * @return String representation of this FitnessTracker
     */
    public String toString() {
        return activity + ", " + minutes + ", " + date;
    }

    
    /**
     * Returns whether the given object is a FitnessTracker that refers to the same
     * activity/minutes/date as this fitnessTracker.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-FitnessTrackers
        if (o instanceof FitnessTracker) {
            FitnessTracker other = (FitnessTracker) o;
            return activity.equals(other.activity) && minutes == other.minutes && date.equals(other.getDate());
        } else {
            return false;
        }
    }
}