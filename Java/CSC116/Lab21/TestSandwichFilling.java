/**
 * Starter code to test SandwichFilling
 * 
 * @author Yan Chen
 */
public class TestSandwichFilling {
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
        SandwichFilling sf1 = new SandwichFilling("chicken",150);
        SandwichFilling sf2 = new SandwichFilling("turkey",100);
        SandwichFilling sf3 = new SandwichFilling("steak",200);
        
        String id = "toString-sf1";
        String desc = "sf1.toString()";
        String exp = "chicken, 150";
        String act = sf1.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-sf2";
        desc = "sf2.toString()";
        exp = "turkey, 100";
        act = sf2.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-sf3";
        desc = "sf3.toString()";
        exp = "steak, 200";
        act = sf3.toString();
        testResult(id, desc, exp, act);
        
        id = "sf1-unequal-sf2";
        desc = "sf1.equals(sf2)";
        boolean expB = false;
        boolean actB = sf1.equals(sf2);
        testResult(id, desc, expB, actB);
        
        id = "sf2-unequal-sf3";
        desc = "sf2.equals(sf3)";
        expB = false;
        actB = sf2.equals(sf3);
        testResult(id, desc, expB, actB);
        
        id = "sf3-unequal-sf1";
        desc = "sf3.equals(sf1)";
        expB = false;
        actB = sf3.equals(sf1);
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
