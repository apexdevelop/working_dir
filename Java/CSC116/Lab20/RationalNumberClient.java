/**
 * Starter code to test RationalNumber
 * 
 * @author Jessica Young Schmidt
 */
public class RationalNumberClient {
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
        RationalNumber quarter = new RationalNumber(1, 4);
        System.out.println("quarter: " + quarter);
        RationalNumber quarterNeg = new RationalNumber(1, -4);
        System.out.println("Negative quarter: " + quarterNeg);
        RationalNumber twoOverEight = new RationalNumber(2, 8);
        System.out.println("twoOverEight: " + twoOverEight);
        RationalNumber third = new RationalNumber(1, 3);
        System.out.println("third: " + third);
        RationalNumber half = new RationalNumber(1, 2);
        System.out.println("half: " + half);

        String id = "Reduction - equals";
        String desc = "quarter.equals(twoOverEight)";
        boolean expB = true;
        boolean actB = quarter.equals(twoOverEight);
        testResult(id, desc, expB, actB);

        id = "Unequal";
        desc = "quarter.equals(third)";
        expB = false;
        actB = quarter.equals(third);
        testResult(id, desc, expB, actB);

        id = "Unequal";
        desc = "quarter.equals(half)";
        expB = false;
        actB = quarter.equals(half);
        testResult(id, desc, expB, actB);
        
        id = "Add 1/4 and 2/8";
        desc = "quarter.add(twoOverEight)";
        RationalNumber exp = half;
        RationalNumber act = quarter.add(twoOverEight);
        testResult(id, desc, exp, act);
        
        id = "Subtract 1/4 and 2/8";
        desc = "quarter.subtract(twoOverEight)";
        exp = new RationalNumber();
        act = quarter.subtract(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Multiply 1/4 and 2/8";
        desc = "quarter.multiply(twoOverEight)";
        exp = new RationalNumber(1, 16);
        act = quarter.multiply(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Divide 1/4 and 2/8";
        desc = "quarter.divide(twoOverEight)";
        exp = new RationalNumber(1, 1);
        act = quarter.divide(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Add -1/4 and 2/8";
        desc = "quarterNeg.add(twoOverEight)";
        exp = new RationalNumber();
        act = quarterNeg.add(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Subtract -1/4 and 2/8";
        desc = "quarterNeg.subtract(twoOverEight)";
        exp = new RationalNumber(1, -2);
        act = quarterNeg.subtract(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Multiply -1/4 and 2/8";
        desc = "quarterNeg.multiply(twoOverEight)";
        exp = new RationalNumber(-1, 16);
        act = quarterNeg.multiply(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Divide -1/4 and 2/8";
        desc = "quarterNeg.divide(twoOverEight)";
        exp = new RationalNumber(-1, 1);
        act = quarterNeg.divide(twoOverEight);
        testResult(id, desc, exp, act);

        id = "Add 1/4 and 1/3";
        desc = "quarter.add(third)";
        exp = new RationalNumber(7, 12);
        act = quarter.add(third);
        testResult(id, desc, exp, act);

        id = "Subtract 1/4 and 1/3";
        desc = "quarter.subtract(third)";
        exp = new RationalNumber(-1, 12);
        act = quarter.subtract(third);
        testResult(id, desc, exp, act);

        id = "Multiply 1/4 and 1/3";
        desc = "quarter.multiply(third)";
        exp = new RationalNumber(1, 12);
        act = quarter.multiply(third);
        testResult(id, desc, exp, act);

        id = "Divide 1/4 and 1/3";
        desc = "quarter.divide(third)";
        exp = new RationalNumber(3, 4);
        act = quarter.divide(third);
        testResult(id, desc, exp, act);

        id = "Add 1/4 and 1/2";
        desc = "quarter.add(half)";
        exp = new RationalNumber(3, 4);
        act = quarter.add(half);
        testResult(id, desc, exp, act);

        id = "Subtract 1/4 and 1/2";
        desc = "quarter.subtract(half)";
        exp = new RationalNumber(-1, 4);
        act = quarter.subtract(half);
        testResult(id, desc, exp, act);

        id = "Multiply 1/4 and 1/2";
        desc = "quarter.multiply(half)";
        exp = new RationalNumber(1, 8);
        act = quarter.multiply(half);
        testResult(id, desc, exp, act);

        id = "Divide 1/4 and 1/2";
        desc = "quarter.divide(half)";
        exp = new RationalNumber(1, 2);
        act = quarter.divide(half);
        testResult(id, desc, exp, act);

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
    private static void testResult(String id, String desc, RationalNumber exp, RationalNumber act) {
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
