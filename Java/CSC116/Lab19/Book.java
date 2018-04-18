import java.util.Date;
    public class Book {
    /** Title of the book */
    private String title;
    /** Author of the book */
    private String author;
    /** Publication year of the book */
    private int pubYear;
    /** Person who has checked out the book */
    private String checkedOut;
    /** Location of the book in the stacks */
    private int location;
    /** Date a checked out book is due */
    private Date dueDate;
    
    /** Constant with number of milliseconds in a day */
    private static final long ONE_DAY = 86400000;
    /** Standard length of checkout in days */
    private static final int CHECKOUT_LENGTH = 90;
    
    
    /** Constructor with parameters but no location */
    //public Book(String title, String author, int pubYear) {
    //    this(title, author, pubYear, 0);
    //}
    
    /** constructor */
    public Book(String title, String author,int pubYear, int location) {
        this.title = title;
        this.author = author;
        this.pubYear = pubYear;
        setLocation(location);
        //location = newLocation;
        this.checkedOut = null;
        this.dueDate = null;
    }
    
    /** Set location of a book
    * @param in loc
    */
    public void setLocation(int loc) {
        if (loc < 0) {
            throw new IllegalArgumentException();
        }
        location = loc;
    }
    
        
    /** Get location of a book
    *@return int location
    */
    public int getLocation() {
        return location;
    }
    
    /** Get title of a book
    *@return String title
    */
    public String getTitle() {
        return title;
    }
    
    /** Get author of a book
    *@return String author
    */
    public String getAuthor() {
        return author;
    }
    
    /** Get pubYear of a book
    *@return int pubYear
    */
    public int getPubYear() {
        return pubYear;
    }

    /**
    * Checks out a book if not already checked out
    *
    * @param unityID
    * unityID to check book out to
    * @return true if a book if not already checked out and it checks it out to
    * the passed in person’s unity id. false if a book is already
    * checked out
    */
    public boolean checkOut(String unityID) {
        if (checkedOut == null) {
            checkedOut = unityID;
            dueDate = new Date(System.currentTimeMillis() + CHECKOUT_LENGTH * ONE_DAY);
            return true;
        }
        return false;
    }
    /**
    * Checks in a book
    */
    public void checkIn() {
        checkedOut = null;
        dueDate = null;
    }
    
    /** Same author, title, and publication year
    *@param Object o
    */
    public boolean equals(Object o) {
        if (o instanceof Book) {
            Book b = (Book) o;
            return title.equals(b.getTitle())
            && author.equals(b.getAuthor())
            && pubYear == b.getPubYear();
        } else {
            return false;
        }
    }
    
    /** Convert to String
    *@return String
    */
    public String toString() {
            String line=title + " by " + author + " in " +pubYear;
            return line;
    }

}