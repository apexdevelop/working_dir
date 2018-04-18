/**
 * Starter code to test Bread
 * 
 * @author Yan Chen
 */
public class TestBread {
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
        Bread b1 = new Bread("rye",50);
        Bread b2 = new Bread("white",75);
        Bread b3 = new Bread("potato",80);
        
        String id = "toString-b1";
        String desc = "b1.toString()";
        String exp = "rye, 50";
        String act = b1.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-b2";
        desc = "b2.toString()";
        exp = "white, 75";
        act = b2.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-b3";
        desc = "b3.toString()";
        exp = "potato, 80";
        act = b3.toString();
        testResult(id, desc, exp, act);
        
        id = "b1-unequal-b2";
        desc = "b1.equals(b2)";
        boolean expB = false;
        boolean actB = b1.equals(b2);
        testResult(id, desc, expB, actB);
        
        id = "b2-unequal-b3";
        desc = "b2.equals(b3)";
        expB = false;
        actB = b2.equals(b3);
        testResult(id, desc, expB, actB);
        
        id = "b3-unequal-b1";
        desc = "b3.equals(b1)";
        expB = false;
        actB = b3.equals(b1);
        testResult(id, desc, expB, actB);
        System.out.printf("\n%4d / %4d passing tests\n", passingTestCounter, testCounter);
    }

    /**
     * Prints the test information.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String id, String desc, String exp, String act) {
        testCounter++;
        String result = FAIL;
        if (exp.equals(act)) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s%-60s%-6s%-42s%-42s\n", id, desc, result, exp, act);
    }

    /**
     * Prints the test information.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String id, String desc, boolean exp, boolean act) {
        testCounter++;
        String result = FAIL;
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s%-60s%-6s%-42s%-42s\n", id, desc, result, exp, act);
    }
}
