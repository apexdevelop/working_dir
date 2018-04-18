/**
 * Program to test MagicSquare
 * 
 * @author David Wright
 * @author <your name here>
 */
public class MagicSquareTest {
    
    /** Constant for passing test output */
    public static final String PASS = "PASS";
    /** Constant for failing test output */
    public static final String FAIL = "FAIL";

    /** Counter for test cases */
    public static int testCounter = 0;
    /** Counter for passing test cases */
    public static int passingTestCounter = 0;

    
    // 2d arrays for testing inputs
    /** Valid multiplicative magic square - # rows == # columns and equal products */
    public static final int[][] VALID_TRUE_1 = {{4, 128, 64}, {512, 32, 2}, {16, 8, 256}};
    
    /** Valid multiplicative magic square - # rows == # columns and equal products */
    public static final int[][] VALID_TRUE_2 = {{18, 1, 12}, {4, 6, 9}, {3, 36, 2}};
    
    /** Valid multiplicative magic square - duplicate numbers in matrix */
    public static final int[][] VALID_FALSE_1 = {{2, 2, 2}, {2, 2, 2}, {2, 2, 2}};
    
    /** Valid multiplicative magic square - products of columns are not equal */
    public static final int[][] VALID_FALSE_2 = {{18, 1, 12}, {4, 6, 9}, {3, 36, 11}};
    
    /** Valid multiplicative magic square - products of diagonals are not equal */
    public static final int[][] VALID_FALSE_3 = {{18, 11, 12}, {4, 6, 9}, {3, 36, 2}};
    
    /** Invalid magic square - more rows than columns */
    public static final int[][] INVALID_1 = {{4, 128, 64}, {512, 32, 2}, {16, 8, 256}, {8, 32, 128}};
    
    /** Invalid magic square - jagged array */
    public static final int[][] INVALID_2 = {{512, 32, 2}, {8, 256}, {4, 128, 64}};
    
    /** Invalid magic square - more columns than rows */
    public static final int[][] INVALID_3 = {{4, 128, 64, 2}, {512, 32, 2, 256}};


  	/**
     * Main executable method
     */
    public static void main(String[] args) {
        testValidMagicSquares();
        
        testInvalidMagicSquares();
        
        System.out.println("\n\n---------------------------------------");
        System.out.println("-               Results               -");
        System.out.println("---------------------------------------");
        System.out.printf("%4d / %4d passing tests\n", passingTestCounter, testCounter);
        System.out.println("---------------------------------------\n\n");
      
	}
    
    /**
     * Test magic squares that are square arrays
     */ 
    public static void testValidMagicSquares() {
        testValidIsMagicSquare1();
        testValidIsMagicSquare2();
        testValidIsMagicSquare3();
        testValidIsMagicSquare4();
        testValidIsMagicSquare5();
        // TO DO:  Add 4 more distinct, non-repetitive test cases here - 
        //         3 that return false and one that returns true
    }
    
    /**
     * Test invalid magic squares
     */
    public static void testInvalidMagicSquares() {
        testInvalidMagicSquare1();
        testInvalidMagicSquare2();
        testInvalidMagicSquare3();
        // TO DO:  Add 1 more distinct, non-repetitive invalid magic square test here
    }
         
    /**
     * Testing isMagicSquare with valid multiplicative magic square
     */
    public static void testValidIsMagicSquare1() {
        String id = "Valid iSM1";
        String desc = "MagicSquare.isMagicSquare(VALID_TRUE_1);";
        boolean expected = true;
        boolean actual = MagicSquare.isMagicSquare(VALID_TRUE_1);
        testResult(id, desc, expected, actual); 
    }
    
    /**
     * Testing isMagicSquare with valid multiplicative magic square
     */
    public static void testValidIsMagicSquare2() {
        String id = "Valid iSM2";
        String desc = "MagicSquare.isMagicSquare(VALID_TRUE_2);";
        boolean expected = true;
        boolean actual = MagicSquare.isMagicSquare(VALID_TRUE_2);
        testResult(id, desc, expected, actual); 
    }
    
    /**
     * Testing isMagicSquare with valid multiplicative magic square
     */
    public static void testValidIsMagicSquare3() {
        String id = "Valid iSM3";
        String desc = "MagicSquare.isMagicSquare(VALID_FALSE_1);";
        boolean expected = false;
        boolean actual = MagicSquare.isMagicSquare(VALID_FALSE_1);
        testResult(id, desc, expected, actual); 
    }
    
    /**
     * Testing isMagicSquare with valid multiplicative magic square
     */
    public static void testValidIsMagicSquare4() {
        String id = "Valid iSM4";
        String desc = "MagicSquare.isMagicSquare(VALID_FALSE_2);";
        boolean expected = false;
        boolean actual = MagicSquare.isMagicSquare(VALID_FALSE_2);
        testResult(id, desc, expected, actual); 
    }
    
    /**
     * Testing isMagicSquare with valid multiplicative magic square
     */
    public static void testValidIsMagicSquare5() {
        String id = "Valid iSM5";
        String desc = "MagicSquare.isMagicSquare(VALID_FALSE_3);";
        boolean expected = false;
        boolean actual = MagicSquare.isMagicSquare(VALID_FALSE_3);
        testResult(id, desc, expected, actual); 
    }
    
    /**
     * Testing isMagicSquare with invalid multiplicative magic square (INVALID_1)
     */
    public static void testInvalidMagicSquare1() {
        String id = "Invalid iSM1";
        String desc = "MagicSquare.isMagicSquare(INVALID_1);";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        String message = "";
        try {
            boolean act = MagicSquare.isMagicSquare(INVALID_1);
        }
        catch (IllegalArgumentException e) {
            actual = e.getClass().toString();
            message = e.getMessage();
        }
        testResult(id, desc, expected, actual, message); 
    }
    
    /**
     * Testing isMagicSquare with invalid multiplicative magic square (INVALID_2)
     */
    public static void testInvalidMagicSquare2() {
        String id = "Invalid iSM2";
        String desc = "MagicSquare.isMagicSquare(INVALID_2);";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        String message = "";
        try {
            boolean act = MagicSquare.isMagicSquare(INVALID_2);
        }
        catch (IllegalArgumentException e) {
            actual = e.getClass().toString();
            message = e.getMessage();
        }
        testResult(id, desc, expected, actual, message); 
    }
    
    /**
     * Testing isMagicSquare with invalid multiplicative magic square (INVALID_3)
     */
    public static void testInvalidMagicSquare3() {
        String id = "Invalid iSM3";
        String desc = "MagicSquare.isMagicSquare(INVALID_3);";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        String message = "";
        try {
            boolean act = MagicSquare.isMagicSquare(INVALID_3);
        }
        catch (IllegalArgumentException e) {
            actual = e.getClass().toString();
            message = e.getMessage();
        }
        testResult(id, desc, expected, actual, message); 
    }
    
    /**
     * Prints the test information for String test values.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     * @param msg message from thrown exception
     */
    private static void testResult(String id, String desc, String exp, String act, String msg) {
        testCounter++;
        String result = FAIL;
        if (exp.equals(act) && !msg.equals("")) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s\n%-30s\n%-6s%s  %s\nException message: %s\n", 
                          id, desc, result, exp, act, msg);
    }
    
    /**
     * Prints the test information for boolean test values.
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
        System.out.printf("%-30s\n%-30s\n%-6s%-7b%7b\n\n", id, desc, result, exp, act);
    }
}
