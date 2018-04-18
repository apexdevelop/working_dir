/**
 * Program to test CabinRental
 * 
 * @author Yan Chen
 */
public class CabinRentalTest {
    
    /** Constant for passing test output */
    public static final String PASS = "PASS";
    /** Constant for failing test output */
    public static final String FAIL = "FAIL";

    /** Counter for test cases */
    public static int testCounter = 0;
    /** Counter for passing test cases */
    public static int passingTestCounter = 0;

    public static void main(String[] args) {
        
        testIsSaturday();

        testGetCabinCost();

        System.out.println("\n\n---------------------------------------");
        System.out.println("-               Results               -");
        System.out.println("---------------------------------------");
        System.out.printf("%4d / %4d passing tests\n", passingTestCounter, testCounter);
        System.out.println("---------------------------------------\n\n");
        
        
    }
    
    /**
     * Testing isSaturday method
     */
    public static void testIsSaturday() {
        System.out.println("***************************************");
        System.out.println("*  Testing isSaturday  *");
        System.out.println("***************************************");
        testIsSaturdayTest1();
        testIsSaturdayTest2();
        testIsSaturdayTest3();
        testIsSaturdayTest4();
        testIsSaturdayTest5();
        testIsSaturdayTest6();
    }
    
    /**
     * Testing getCabinCost method 
     */
    public static void testGetCabinCost() {
        System.out.println("\n***************************************");
        System.out.println("*  Testing getCabinCost  *");
        System.out.println("***************************************");
        testGetCabinCostValid1();
        testGetCabinCostValid2();
        testGetCabinCostValid3();
        testGetCabinCostValid4();
        testGetCabinCostValid5();
        testGetCabinCostValid6();
        testGetCabinCostValid7();
        testGetCabinCostValid8();
        testGetCabinCostValid9();

        testGetCabinCostInvalid();
    }

    /**
     * Testing isStaturday with March 3, 2012 - a Saturday
     */
    public static void testIsSaturdayTest1() {
        String id = "Saturday, March 3, 2012";
        String desc = "CabinRental.isSaturday(3, 3, 2012)";
        String expected = "true";
        String actual = "" + CabinRental.isSaturday(3, 3, 2012);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing isStaturday with Nov 7, 2016 - a Monday
     */
    public static void testIsSaturdayTest2() {
        String id = "Monday, Nov 7, 2016";
        String desc = "CabinRental.isSaturday(11, 7, 2016)";
        String expected = "false";
        String actual = "" + CabinRental.isSaturday(11, 7, 2016);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing isStaturday with Nov 8, 2016 - a Tuesday
     */
    public static void testIsSaturdayTest3() {
        String id = "Tuesday, Nov 8, 2016";
        String desc = "CabinRental.isSaturday(11, 8, 2016)";
        String expected = "false";
        String actual = "" + CabinRental.isSaturday(11, 8, 2016);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing isStaturday with Nov 9, 2016 - a Wednesday
     */
    public static void testIsSaturdayTest4() {
        String id = "Wednesday, Nov 9, 2016";
        String desc = "CabinRental.isSaturday(11, 9, 2016)";
        String expected = "false";
        String actual = "" + CabinRental.isSaturday(11, 9, 2016);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing isStaturday with Nov 10, 2016 - a Thursday
     */
    public static void testIsSaturdayTest5() {
        String id = "Thursday, Nov 10, 2016";
        String desc = "CabinRental.isSaturday(11, 10, 2016)";
        String expected = "false";
        String actual = "" + CabinRental.isSaturday(11, 10, 2016);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing isStaturday with Nov 11, 2016 - a Friday
     */
    public static void testIsSaturdayTest6() {
        String id = "Friday, Nov 11, 2016";
        String desc = "CabinRental.isSaturday(11, 11, 2016)";
        String expected = "false";
        String actual = "" + CabinRental.isSaturday(11, 11, 2016);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Red and White Rambler on 11/12
     */
    public static void testGetCabinCostValid1() {
        String id = "Red and White Rambler on 11/12";
        String desc = "CabinRental.getCabinCost('r', 11, 12)";
        String expected = "500";
        String actual = "" + CabinRental.getCabinCost('r', 11, 12);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Wolfpack Heaven on 11/12
     */
    public static void testGetCabinCostValid2() {
        String id = "Wolfpack Heaven on 11/12";
        String desc = "CabinRental.getCabinCost('w', 11, 12)";
        String expected = "650";
        String actual = "" + CabinRental.getCabinCost('w', 11, 12);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Belltower Bliss on 11/12
     */
    public static void testGetCabinCostValid3() {
        String id = "Belltower Bliss on 11/12";
        String desc = "CabinRental.getCabinCost('b', 11, 12)";
        String expected = "700";
        String actual = "" + CabinRental.getCabinCost('b', 11, 12);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Red and White Rambler on 11/19
     */
    public static void testGetCabinCostValid4() {
        String id = "Red and White Rambler on 11/19";
        String desc = "CabinRental.getCabinCost('r', 11, 19)";
        String expected = "800";
        String actual = "" + CabinRental.getCabinCost('r', 11, 19);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Wolfpack Heaven on 11/19
     */
    public static void testGetCabinCostValid5() {
        String id = "Wolfpack Heaven on 11/19";
        String desc = "CabinRental.getCabinCost('w', 11, 19)";
        String expected = "900";
        String actual = "" + CabinRental.getCabinCost('w', 11, 19);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Belltower Bliss on 11/19
     */
    public static void testGetCabinCostValid6() {
        String id = "Belltower Bliss on 11/19";
        String desc = "CabinRental.getCabinCost('b', 11, 19)";
        String expected = "950";
        String actual = "" + CabinRental.getCabinCost('b', 11, 19);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Red and White Rambler on 12/24
     */
    public static void testGetCabinCostValid7() {
        String id = "Red and White Rambler on 12/24";
        String desc = "CabinRental.getCabinCost('r', 12, 24)";
        String expected = "1000";
        String actual = "" + CabinRental.getCabinCost('r', 12, 24);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Wolfpack Heaven on 12/24
     */
    public static void testGetCabinCostValid8() {
        String id = "Wolfpack Heaven on 12/24";
        String desc = "CabinRental.getCabinCost('w', 12, 24)";
        String expected = "1200";
        String actual = "" + CabinRental.getCabinCost('w', 12, 24);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Valid Cabin Cost - Belltower Bliss on 12/24
     */
    public static void testGetCabinCostValid9() {
        String id = "Belltower Bliss on 12/24";
        String desc = "CabinRental.getCabinCost('b', 12, 24)";
        String expected = "1350";
        String actual = "" + CabinRental.getCabinCost('b', 12, 24);
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Invalid Cabin Cost - cabin code, date
     */
    public static void testGetCabinCostInvalid() {
        String id = "Invalid Cabin Rental cabin code - 'x'";
        String desc = "CabinRental.getCabinCost('x', 11, 5);";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            actual = "" + CabinRental.getCabinCost('x', 11, 5);
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);

        id = "Invalid Cabin Rental - day not a Saturday";
        desc = "CabinRental.getCabinCost('r', 11, 6)";
        expected = "class java.lang.IllegalArgumentException";
        actual = "";
        try {
            actual = "" + CabinRental.getCabinCost('r', 11, 6);
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
        System.out.printf("%-30s\n%-30s\n%-6s%-40s%7s\n\n", id, desc, result, exp, act);
    }
}