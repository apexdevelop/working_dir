/**
 * Program to test TriangleClassification
 * 
 * @author Jessica Young Schmidt
 * @author Yan Chen
 */
public class TriangleClassificationTest {

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
        testIsValidTriangleSideLength();

        testGetTriangleTypeSideLength();

        testIsValidTriangleAngle();

        testGetTriangleTypeAngle();

        System.out.println("\n---------------------------------------");
        System.out.println("-               Results               -");
        System.out.println("---------------------------------------");
        System.out.printf("%4d / %4d passing tests", passingTestCounter, testCounter);

    }

    /**
     * Testing isValidTriangleSideLength method
     */
    public static void testIsValidTriangleSideLength() {
        System.out.println("***************************************");
        System.out.println("*  Testing isValidTriangleSideLength  *");
        System.out.println("***************************************");
        testIsValidTriangleSideLengthAZero();

        // TODO Add 5 more test cases here for isValidTriangleSideLength method
        testIsValidTriangleSideLengthBZero();
        testIsValidTriangleSideLengthCZero();
        testIsValidTriangleSideLengthANegative();
        testIsValidTriangleSideLengthBNegative();
        testIsValidTriangleSideLengthABlessC();
    }

    /**
     * Testing side A value of 0 - Invalid
     */
    public static void testIsValidTriangleSideLengthAZero() {
        String id = "Invalid Side A of Zero";
        String desc = "TriangleClassification.isValidTriangleSideLength(0, 2, 2)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleSideLength(0, 2, 2);
        testResult(id, desc, expected, actual);
    }
    
     /**
     * Testing side B value of 0 - Invalid
     */
    public static void testIsValidTriangleSideLengthBZero() {
        String id = "Invalid Side B of Zero";
        String desc = "TriangleClassification.isValidTriangleSideLength(2, 0, 2)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleSideLength(2, 0, 2);
        testResult(id, desc, expected, actual);
    }
    
     /**
     * Testing side C value of 0 - Invalid
     */
    public static void testIsValidTriangleSideLengthCZero() {
        String id = "Invalid Side C of Zero";
        String desc = "TriangleClassification.isValidTriangleSideLength(2, 2, 0)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleSideLength(2, 2, 0);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing side A Negative - Invalid
     */
    public static void testIsValidTriangleSideLengthANegative() {
        String id = "Invalid Side Negative A";
        String desc = "TriangleClassification.isValidTriangleSideLength(-1, 2, 2)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleSideLength(-1, 2, 2);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing side B negative - Invalid
     */
    public static void testIsValidTriangleSideLengthBNegative() {
        String id = "Invalid Side Negative B";
        String desc = "TriangleClassification.isValidTriangleSideLength(2, -1, 2)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleSideLength(2, -1, 2);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing side A and side B less than side C - Invalid
     */
    public static void testIsValidTriangleSideLengthABlessC() {
        String id = "Invalid Side A and Side B less than Side C";
        String desc = "TriangleClassification.isValidTriangleSideLength(2, 2, 5)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleSideLength(2, 2, 5);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing getTriangleTypeSideLength method
     */
    public static void testGetTriangleTypeSideLength() {
        System.out.println("\n***************************************");
        System.out.println("*  Testing getTriangleTypeSideLength  *");
        System.out.println("***************************************");
        testGetTriangleTypeSideLengthEquilateral();

        // TODO Add 5 more test cases here for getTriangleTypeSideLength method
        testGetTriangleTypeSideLengthIsoscelesAB();
        testGetTriangleTypeSideLengthIsoscelesBC();
        testGetTriangleTypeSideLengthIsoscelesAC();
        testGetTriangleTypeSideLengthScalene();
        // Invalid test cases are provided for you below - You do NOT
        // need to add additional invalid tests. Just make sure these
        // pass!
        testGetTriangleTypeSideLengthInvalid();
    }

    /**
     * Testing Equilateral
     */
    public static void testGetTriangleTypeSideLengthEquilateral() {
        String id = "Equilateral Triangle";
        String desc = "TriangleClassification.getTriangleTypeSideLength(2, 2, 2)";
        String expected = "Equilateral";
        String actual = TriangleClassification.getTriangleTypeSideLength(2, 2, 2);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Isosceles AB
     */
    public static void testGetTriangleTypeSideLengthIsoscelesAB() {
        String id = "Isosceles Triangle AB";
        String desc = "TriangleClassification.getTriangleTypeSideLength(4, 4, 2)";
        String expected = "Isosceles";
        String actual = TriangleClassification.getTriangleTypeSideLength(4, 4, 2);
        testResult(id, desc, expected, actual);
    }
    
     /**
     * Testing Isosceles BC
     */
    public static void testGetTriangleTypeSideLengthIsoscelesBC() {
        String id = "Isosceles Triangle BC";
        String desc = "TriangleClassification.getTriangleTypeSideLength(2, 4, 4)";
        String expected = "Isosceles";
        String actual = TriangleClassification.getTriangleTypeSideLength(2, 4, 4);
        testResult(id, desc, expected, actual);
    }
    
         /**
     * Testing Isosceles AC
     */
    public static void testGetTriangleTypeSideLengthIsoscelesAC() {
        String id = "Isosceles Triangle AC";
        String desc = "TriangleClassification.getTriangleTypeSideLength(4, 2, 4)";
        String expected = "Isosceles";
        String actual = TriangleClassification.getTriangleTypeSideLength(4, 2, 4);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Scalene
     */
    public static void testGetTriangleTypeSideLengthScalene() {
        String id = "Scalene Triangle";
        String desc = "TriangleClassification.getTriangleTypeSideLength(3, 4, 5)";
        String expected = "Scalene";
        String actual = TriangleClassification.getTriangleTypeSideLength(3, 4, 5);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing Invalid Triangle Side Length
     */
    public static void testGetTriangleTypeSideLengthInvalid() {
        String id = "Invalid Triangle - zero";
        String desc = "TriangleClassification.getTriangleTypeSideLength(0, 3, 4)";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            actual = TriangleClassification.getTriangleTypeSideLength(0, 3, 4);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);

        id = "Invalid Triangle";
        desc = "TriangleClassification.getTriangleTypeSideLength(10, 4, 3)";
        expected = "class java.lang.IllegalArgumentException";
        actual = "";
        try {
            actual = TriangleClassification.getTriangleTypeSideLength(10, 4, 3);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing isValidTriangleAngle method
     */
    public static void testIsValidTriangleAngle() {
        System.out.println("\n***************************************");
        System.out.println("*     Testing isValidTriangleAngle    *");
        System.out.println("***************************************");
        testIsValidTriangleAngleAZero();        
        testIsValidTriangleAngleBZero();
        testIsValidTriangleAngleCNegative();
        testIsValidTriangleAngleBig();
        testIsValidTriangleAngleSmall();
        // TODO Add 5 more test cases here for isValidTriangleAngle method
    }

    /**
     * Testing angle A value of 0 - Invalid
     */
    public static void testIsValidTriangleAngleAZero() {
        String id = "Invalid Angle A of Zero";
        String desc = "TriangleClassification.isValidTriangleAngle(0, 90, 90)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleAngle(0, 90, 90);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing angle B value of 0 - Invalid
     */
    public static void testIsValidTriangleAngleBZero() {
        String id = "Invalid Angle B of Zero";
        String desc = "TriangleClassification.isValidTriangleAngle(90, 0, 90)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleAngle(90, 0, 90);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing angle C value of negative - Invalid
     */
    public static void testIsValidTriangleAngleCNegative() {
        String id = "Invalid Angle C of Negative";
        String desc = "TriangleClassification.isValidTriangleAngle(90, 90, -90)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleAngle(90, 90, -90);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing angle sum more than 180 - Invalid
     */
    public static void testIsValidTriangleAngleBig() {
        String id = "Invalid Angle sum more than 180";
        String desc = "TriangleClassification.isValidTriangleAngle(90, 90, 90)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleAngle(90, 90, 90);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing angle sum less than 180 - Invalid
     */
    public static void testIsValidTriangleAngleSmall() {
        String id = "Invalid Angle sum less than 180";
        String desc = "TriangleClassification.isValidTriangleAngle(20, 20, 20)";
        String expected = "false";
        String actual = "" + TriangleClassification.isValidTriangleAngle(20, 20, 20);
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing getTriangleTypeAngle method
     */
    public static void testGetTriangleTypeAngle() {
        System.out.println("\n***************************************");
        System.out.println("*    Testing getTriangleTypeAngle     *");
        System.out.println("***************************************");
        testGetTriangleTypeAngleARight();
        testGetTriangleTypeAngleCRight();
        testGetTriangleTypeAngleAcute();
        testGetTriangleTypeAngleAObtuse();
        testGetTriangleTypeAngleCObtuse();
        // TODO Add 5 more test cases here for testGetTriangleTypeAngle method

        // Invalid test cases are provided for you below - You do NOT
        // need to add additional invalid tests. Just make sure these
        // pass!
        testGetTriangleTypeAngleInvalid();
    }

    /**
     * Testing Invalid Triangle Angles
     */
    public static void testGetTriangleTypeAngleInvalid() {
        String id = "Invalid Triangle - zero";
        String desc = "TriangleClassification.getTriangleTypeAngle(0, 90, 90)";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            actual = TriangleClassification.getTriangleTypeAngle(0, 90, 90);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);

        id = "Invalid Triangle - sum 90";
        desc = "TriangleClassification.getTriangleTypeAngle(30, 30, 30)";
        expected = "class java.lang.IllegalArgumentException";
        actual = "";
        try {
            actual = TriangleClassification.getTriangleTypeAngle(30, 30, 30);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);
    }

    /**
     * Testing Right Angle A
     */
    public static void testGetTriangleTypeAngleARight() {
        String id = "Right Triangle A";
        String desc = "TriangleClassification.getTriangleTypeAngle(90, 30, 60)";
        String expected = "Right";
        String actual = TriangleClassification.getTriangleTypeAngle(90, 30, 60);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Right Angle C
     */
    public static void testGetTriangleTypeAngleCRight() {
        String id = "Right Triangle C";
        String desc = "TriangleClassification.getTriangleTypeAngle(60, 30, 90)";
        String expected = "Right";
        String actual = TriangleClassification.getTriangleTypeAngle(60, 30, 90);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Acute Angle
     */
    public static void testGetTriangleTypeAngleAcute() {
        String id = "Acute Triangle";
        String desc = "TriangleClassification.getTriangleTypeAngle(60, 60, 60)";
        String expected = "Acute";
        String actual = TriangleClassification.getTriangleTypeAngle(60, 60, 60);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Obtuse Angle A
     */
    public static void testGetTriangleTypeAngleAObtuse() {
        String id = "Obtuse Triangle A";
        String desc = "TriangleClassification.getTriangleTypeAngle(120, 40, 20)";
        String expected = "Obtuse";
        String actual = TriangleClassification.getTriangleTypeAngle(120, 40, 20);
        testResult(id, desc, expected, actual);
    }
    
     /**
     * Testing Obtuse Angle C
     */
    public static void testGetTriangleTypeAngleCObtuse() {
        String id = "Obtuse Triangle C";
        String desc = "TriangleClassification.getTriangleTypeAngle(20, 40, 120)";
        String expected = "Obtuse";
        String actual = TriangleClassification.getTriangleTypeAngle(20, 40, 120);
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