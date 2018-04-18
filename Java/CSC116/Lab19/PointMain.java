/** A program that deals with 2D points.
* Second version, to accompany Point class with behavior.
*/

public class PointMain {
    /** Constant for passing test output */
    public static final String PASS = "PASS";
    /** Constant for failing test output */
    public static final String FAIL = "FAIL";

    /** Counter for test cases */
    public static int testCounter = 0;
    /** Counter for passing test cases */
    public static int passingTestCounter = 0;
    
    
    /**
     * Starts program
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
        // create two Point objects
        Point p1 = new Point();
        p1.x = 7;
        p1.y = 2;

        Point p2 = new Point();
        p2.x = 4;
        p2.y = 3;

        // print each point and its distance from origin
        System.out.println("p1 is (" + p1.x + ", " + p1.y + ")");
        System.out.println("distance from origin = " +
                           p1.distanceFromOrigin());

        System.out.println("p2 is (" + p2.x + ", " + p2.y + ")");
        System.out.println("distance from origin = " +
                           p2.distanceFromOrigin());
        
        // translate each point to a new location
        p1.translate(11, 6);
        p2.translate(1, 7);

        // print the points again
        System.out.println("p1 is (" + p1.x + ", " + p1.y + ")");
        System.out.println("p2 is (" + p2.x + ", " + p2.y + ")");        
        
        //test distance method
        int dx = p1.x - p2.x;
        int dy = p1.y - p2.y;
        double dist;
        dist=Math.sqrt(dx*dx + dy*dy );
        testResult("Test distance", dist, p1.distance(p2));
        
        //test manhattanDistance method
        dx = p1.x - p2.x;
        dy = p1.y - p2.y;
        double manDist;
        manDist=Math.abs(dx) + Math.abs(dy);
        testResult("Test manhattanDistance", manDist, p1.manhattanDistance(p2));
        
        //test quadrant method
        Point p3 = new Point();
        p3.x = -6;
        p3.y = 1;
        
        Point p4 = new Point();
        p4.x = 3;
        p4.y = -1;
        
        Point p5 = new Point();
        p5.x = -4;
        p5.y = -2;
        
        Point p6 = new Point();
        p6.x = 0;
        p6.y = 4;
        
        Point p7 = new Point();
        p7.x = 4;
        p7.y = 0;
        
        Point p8 = new Point();
        p8.x = 0;
        p8.y = 0;
        
        testResult("Test 1st quadrant", 1, p1.quadrant());
        testResult("Test 2nd quadrant", 2, p3.quadrant());
        testResult("Test 3rd quadrant", 3, p4.quadrant());
        testResult("Test 4th quadrant", 4, p5.quadrant());
        testResult("Test y axis", 0, p6.quadrant());
        testResult("Test x axis", 0, p7.quadrant());
        testResult("Test origin", 0, p8.quadrant());
        System.out.printf("%4d / %4d passing tests\n", passingTestCounter, testCounter);
    }
    
     /**
     * Prints the test information.
     * 
     * @param info description of the test
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String info, double exp, double act) {
        testCounter++;
        String result = FAIL;
        if (exp==act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-40s%-6s%-32s%-32s\n", info, result, exp, act);
    }
    
    /**
     * Prints the test information.
     * 
     * @param info description of the test
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String info, int exp, int act) {
        testCounter++;
        String result = FAIL;
        if (exp==act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-40s%-6s%-32s%-32s\n", info, result, exp, act);
    }
}