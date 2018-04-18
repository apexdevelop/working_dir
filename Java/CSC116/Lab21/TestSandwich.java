/**
 * Starter code to test Sandwich
 * 
 * @author Yan Chen
 */
public class TestSandwich {
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
        
        SandwichFilling sf1 = new SandwichFilling("chicken",150);
        SandwichFilling sf2 = new SandwichFilling("turkey",100);
        SandwichFilling sf3 = new SandwichFilling("steak",200);
        
        Sandwich s1 = new Sandwich(b1,sf1);
        Sandwich s2 = new Sandwich(b2,sf2);
        Sandwich s3 = new Sandwich(b3,sf3);
        
        String id = "toString-s1";
        String desc = "s1.toString()";
        String exp = "rye, 50/chicken, 150";
        String act = s1.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-s2";
        desc = "s2.toString()";
        exp = "white, 75/turkey, 100";
        act = s2.toString();
        testResult(id, desc, exp, act);
        
        id = "toString-s3";
        desc = "s3.toString()";
        exp = "potato, 80/steak, 200";
        act = s3.toString();
        testResult(id, desc, exp, act);
        
        id = "s1-unequal-s2";
        desc = "s1.equals(s2)";
        boolean expB = false;
        boolean actB = s1.equals(s2);
        testResult(id, desc, expB, actB);
        
        id = "s2-unequal-s3";
        desc = "s2.equals(s3)";
        expB = false;
        actB = s2.equals(s3);
        testResult(id, desc, expB, actB);
        
        id = "s3-unequal-s1";
        desc = "s3.equals(s1)";
        expB = false;
        actB = s3.equals(s1);
        testResult(id, desc, expB, actB);
        
        id = "s1-totalCalories";
        desc = "s1.totalCalories()";
        int expi = 250;
        int acti = s1.totalCalories();
        testResult(id, desc, expi, acti);
        
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
    
     /**
     * Prints the test information.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String id, String desc, int exp, int act) {
        testCounter++;
        String result = FAIL;
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s%-60s%-6s%-42s%-42s\n", id, desc, result, exp, act);
    }
}
