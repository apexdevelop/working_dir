/**
 * Starter code to test FitnessTracker
 * 
 * @author Yan Chen
 */
public class TestFitnessTracker {
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
        FitnessTracker f1 = new FitnessTracker();
        //System.out.println(f1.toString());
        FitnessTracker f2 = new FitnessTracker();
        FitnessTracker f3 = new FitnessTracker("swimming",20,new Date(2016,11,11));
        
        String id = "toString-Defalut";
        String desc = "f1.toString()";
        String exp = "running, 0, 2016/1/1";
        String act = f1.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-overload";
        desc = "f3.toString()";
        exp = "swimming, 20, 2016/11/11";
        act = f3.toString();
        testResult(id, desc, exp, act);

        id = "equal";
        desc = "f1.equals(f2)";
        boolean expB = true;
        boolean actB = f1.equals(f2);
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
