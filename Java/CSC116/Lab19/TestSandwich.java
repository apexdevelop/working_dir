/**
 * Test code for Sandwich class
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
        testSandwich();

    }
        
    /**
     * Testing name class
     */
    public static void testSandwich() {
        Sandwich s1 = new Sandwich();
        Sandwich s2 = new Sandwich();
        Sandwich s3 = new Sandwich();
        Sandwich s4 = new Sandwich();
        s1.setIngredient("tuna");
        s2.setIngredient("chicken");
        s3.setIngredient("steak");
        s4.setIngredient("ham");
        s1.setBread("wheat");
        s2.setBread("rye");
        s3.setBread("white");
        s4.setBread("potato");
        s1.setPrice(4.99);
        s2.setPrice(5.99);
        s3.setPrice(6.99);
        s4.setPrice(7.99);
        testResult("Test ingredient 1", "tuna", s1.getIngredient());
        testResult("Test ingredient 2", "chicken", s2.getIngredient());
        testResult("Test ingredient 3", "steak", s3.getIngredient());
        testResult("Test ingredient 4", "ham", s4.getIngredient());
        testResult("Test bread 1", "wheat", s1.getBread());
        testResult("Test bread 2", "rye", s2.getBread());
        testResult("Test bread 3", "white", s3.getBread());
        testResult("Test bread 4", "potato", s4.getBread());
        testResult("Test price 1", 4.99, s1.getPrice());
        testResult("Test price 2", 5.99, s2.getPrice());
        testResult("Test price 3", 6.99, s3.getPrice());
        testResult("Test price 4", 7.99, s4.getPrice());
        System.out.printf("%4d / %4d passing tests\n", passingTestCounter, testCounter);

    }

    /**
     * Prints the test information.
     * 
     * @param info description of the test
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String info, String exp, String act) {
        testCounter++;
        String result = FAIL;
        if (exp.equals(act)) {
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
    private static void testResult(String info, double exp, double act) {
        testCounter++;
        String result = FAIL;
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-40s%-6s%-32s%-32s\n", info, result, exp, act);
    }

}
