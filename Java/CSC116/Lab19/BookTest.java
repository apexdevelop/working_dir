public class BookTest {
    public static void main(String[] args) {
        testBookCreation();
        testCheckOutIn();
        testLocation();
        testEquals();
        testString();
    }
    // Test the default constructor
    public static void testBookCreation() {
        //Book b = new Book();
        //b.title = "Building Java Programs: A Back to Basics Approach";
        //b.author = "Stuart Reges and Marty Stepp";
        //b.pubYear = 2013;
        //b.checkedOut = null;
        //b.location = 1;
        //b.dueDate = null;
        Book b = new Book("Building Java Programs: A Back to Basics Approach",
        "Stuart Reges and Marty Stepp", 2013, 1);
        System.out.println("Expected:\tBuilding Java Programs: "
        + "A Back to Basics Approach (2013)" + "\nActual:\t\t" + b.getTitle()
        + " (" + b.getPubYear() + ")");
    }
    
    public static void testCheckOutIn() {
        Book b = new Book("Building Java Programs: A Back to Basics Approach",
        "Stuart Reges and Marty Stepp", 2013, 1);
        System.out.println("Expected:\ttrue" + "\nActual:\t\t"
        + b.checkOut("jdyoung2"));
        System.out.println("Expected:\tfalse" + "\nActual:\t\t"
        + b.checkOut("jdoe"));
        b.checkIn();
        System.out.println("Expected:\ttrue" + "\nActual:\t\t"
        + b.checkOut("jdoe"));
    }
    
    public static void testLocation() {
        Book b = new Book("Building Java Programs: A Back to Basics Approach",
        "Stuart Reges and Marty Stepp", 2013, 1);
        System.out.println("Expected:\t1" + "\nActual:\t\t" + b.getLocation());
        b.setLocation(3);
        System.out.println("Expected:\t3" + "\nActual:\t\t" + b.getLocation());
    }
    
    public static void testEquals() {
        Book[] book = new Book[2];
        book[0] = new Book("Building Java Programs: A Back to Basics Approach",
        "Stuart Reges and Marty Stepp", 2013, 1);
        book[1] = new Book("Java Precisely", "Peter Sestoft", 2005, 5);
        //Book b1 = new Book();
        //b1.title = "Building Java Programs: A Back to Basics Approach";
        //b1.author = "Stuart Reges and Marty Stepp";
        //b1.pubYear = 2013;
        //Book b2 = new Book();
        //b2.title = "Building Java Programs: A Back to Basics Approach";
        //b2.author = "Stuart Reges and Marty Stepp";
        //b2.pubYear = 2013;
        System.out.println("Expected:\tfalse" + "\nActual:\t\t" + book[0].equals(book[1]));
    }
    
    public static void testString() {
        Book b = new Book("Building Java Programs: A Back to Basics Approach",
        "Stuart Reges and Marty Stepp", 2013, 1);
        System.out.println("Expected:\tBuilding Java Programs: "
        + "A Back to Basics Approach by Stuart Reges and Marty Stepp in 2013" + "\nActual:\t\t" + b.toString());
    }
}