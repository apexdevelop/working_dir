/**
 * Program to test DecimalToBinary
 * 
 * @author Jessica Young Schmidt
 * @author Yan Chen
 */
public class DecimalToBinaryTest {

    /** Constant for passing test output */
    public static final String PASS = "PASS";
    /** Constant for failing test output */
    public static final String FAIL = "FAIL";

    /** Counter for test cases */
    public static int testCounter = 0;
    /** Counter for passing test cases */
    public static int passingTestCounter = 0;

    /**
     * The method that is executed when the program is run
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {

        testConvertToBinaryInvalid();
        testConvertToBinaryValid();

        System.out.println("\n---------------------------------------");
        System.out.println("-               Results               -");
        System.out.println("---------------------------------------");
        System.out.printf("%4d / %4d passing tests", passingTestCounter, testCounter);

    }

    /**
     * Testing convertToBinary method with valid values
     */
    public static void testConvertToBinaryValid() {
        // Zero - special case
        String id = "Zero";
        String desc = "DecimalToBinary.convertToBinary(0)";
        String expected = "0";
        String actual = DecimalToBinary.convertToBinary(0);
        testResult(id, desc, expected, actual);
        
        // 20
        id = "20";
        desc = "DecimalToBinary.convertToBinary(20)";
        expected = "10100";
        actual = DecimalToBinary.convertToBinary(20);
        testResult(id, desc, expected, actual);
        
        // 200
        id = "200";
        desc = "DecimalToBinary.convertToBinary(200)";
        expected = "11001000";
        actual = DecimalToBinary.convertToBinary(200);
        testResult(id, desc, expected, actual);
        
        // 2000
        id = "2000";
        desc = "DecimalToBinary.convertToBinary(2000)";
        expected = "11111010000";
        actual = DecimalToBinary.convertToBinary(2000);
        testResult(id, desc, expected, actual);
        
        // 20000
        id = "20000";
        desc = "DecimalToBinary.convertToBinary(20000)";
        expected = "100111000100000";
        actual = DecimalToBinary.convertToBinary(20000);
        testResult(id, desc, expected, actual);

    }

    /**
     * Testing Invalid values to convertToBinary
     */
    public static void testConvertToBinaryInvalid() {
        String id = "Invalid value: -1";
        String desc = "DecimalToBinary.convertToBinary(-1)";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            actual = DecimalToBinary.convertToBinary(-1);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);

        id = "Invalid value: -2468";
        desc = "DecimalToBinary.convertToBinary(-2468)";
        expected = "class java.lang.IllegalArgumentException";
        actual = "";
        try {
            actual = DecimalToBinary.convertToBinary(-2468);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);
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

}
