/**
 * Program testing Cipher.java
 * @author Yan Chen
 */
public class CipherTest {
    
    /** Constant for passing test output */
    public static final String PASS = "PASS";
    /** Constant for failing test output */
    public static final String FAIL = "FAIL";

    /** Counter for test cases */
    public static int testCounter = 0;
    /** Counter for passing test cases */
    public static int passingTestCounter = 0;

    public static void main(String[] args) {
        testEncryptLine();

        testDecryptLine();
        
        testProcessFileInvalid();

        System.out.println("\n\n---------------------------------------");
        System.out.println("-               Results               -");
        System.out.println("---------------------------------------");
        System.out.printf("%4d / %4d passing tests\n", passingTestCounter, testCounter);
        System.out.println("---------------------------------------\n\n");
    }
    
    /**
     * Testing encryptLine method
     */
    public static void testEncryptLine() {
        System.out.println("***************************************");
        System.out.println("*  Testing encryptLine  *");
        System.out.println("***************************************");
        testEncryptLine1();

        // TODO Add 5 more test cases here for encryptLine method
        testEncryptLine2();
        testEncryptLine3();
        testEncryptLine4();
        testEncryptLine5();
        testEncryptLine6();
        testEncryptLineInvalid();
    }
    
    /**
     * Testing decryptLine method
     */
    public static void testDecryptLine() {
        System.out.println("***************************************");
        System.out.println("*  Testing decryptLine  *");
        System.out.println("***************************************");
        testDecryptLine1();

        // TODO Add 5 more test cases here for decryptLine method
        testDecryptLine2();
        testDecryptLine3();
        testDecryptLine4();
        testDecryptLine5();
        testDecryptLine6();
        testDecryptLineInvalid();
    }
    
    /**
     * Testing encryptLine with shift of 5, and line: "Pop Quiz Today!"
     */
    public static void testEncryptLine1() {
        String id = "5, \"Pop Quiz Today!\"";
        String desc = "Cipher.encryptLine(5, \"Pop Quiz Today!\");";
        String expected = "Utu Vzne Ytifd!";
        String actual = "" + Cipher.encryptLine(5, "Pop Quiz Today!");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing encryptLine with shift of 1, and line: "Pop Quiz Today!"
     */
    public static void testEncryptLine2() {
        String id = "1, \"Pop Quiz Today!\"";
        String desc = "Cipher.encryptLine(1, \"Pop Quiz Today!\");";
        String expected = "Qpq Rvja Upebz!";
        String actual = "" + Cipher.encryptLine(1, "Pop Quiz Today!");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing encryptLine with shift of 25, and line: "Pop Quiz Today!"
     */
    public static void testEncryptLine3() {
        String id = "25, \"Pop Quiz Today!\"";
        String desc = "Cipher.encryptLine(25, \"Pop Quiz Today!\");";
        String expected = "Ono Pthy Snczx!";
        String actual = "" + Cipher.encryptLine(25, "Pop Quiz Today!");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 5, and line: "CT 56 31 7 Oct U. of Connecticut"
     */
    public static void testEncryptLine4() {
        String id = "5, \"CT 56 31 7 Oct U. of Connecticut\"";
        String desc = "Cipher.encryptLine(5, \"CT 56 31 7 Oct U. of Connecticut\");";
        String expected = "HY 56 31 7 Thy Z. tk Htssjhynhzy";
        String actual = "" + Cipher.encryptLine(5, "CT 56 31 7 Oct U. of Connecticut");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 1, and line: "ABCDE"
     */
    public static void testEncryptLine5() {
        String id = "1, \"ABCDE\"";
        String desc = "Cipher.encryptLine(1, \"ABCDE\");";
        String expected = "BCDEF";
        String actual = "" + Cipher.encryptLine(1, "ABCDE");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 25, and line: "ABCDE"
     */
    public static void testEncryptLine6() {
        String id = "25, \"ABCDE\"";
        String desc = "Cipher.encryptLine(25, \"ABCDE\");";
        String expected = "ZABCD";
        String actual = "" + Cipher.encryptLine(25, "ABCDE");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 5, and line: "Utu Vzne Ytifd!"
     */
    public static void testDecryptLine1() {
        String id = "5, \"Utu Vzne Ytifd!\"";
        String desc = "Cipher.decryptLine(5, \"Utu Vzne Ytifd!\");";
        String expected = "Pop Quiz Today!";
        String actual = "" + Cipher.decryptLine(5, "Utu Vzne Ytifd!");
        testResult(id, desc, expected, actual);
    }
    
     /**
     * Testing decryptLine with shift of 1, and line: "Qpq Rvja Upebz!"
     */
    public static void testDecryptLine2() {
        String id = "1, \"Qpq Rvja Upebz!\"";
        String desc = "Cipher.decryptLine(1, \"Qpq Rvja Upebz!\");";
        String expected = "Pop Quiz Today!";
        String actual = "" + Cipher.decryptLine(1, "Qpq Rvja Upebz!");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 25, and line: "Ono Pthy Snczx!"
     */
    public static void testDecryptLine3() {
        String id = "25, \"Ono Pthy Snczx!\"";
        String desc = "Cipher.decryptLine(1, \"Ono Pthy Snczx!\");";
        String expected = "Pop Quiz Today!";
        String actual = "" + Cipher.decryptLine(25, "Ono Pthy Snczx!");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 5, and line: "HY 56 31 7 Thy Z. tk Htssjhynhzy"
     */
    public static void testDecryptLine4() {
        String id = "5, \"HY 56 31 7 Thy Z. tk Htssjhynhzy\"";
        String desc = "Cipher.decryptLine(5, \"HY 56 31 7 Thy Z. tk Htssjhynhzy\");";
        String expected = "CT 56 31 7 Oct U. of Connecticut";
        String actual = "" + Cipher.decryptLine(5, "HY 56 31 7 Thy Z. tk Htssjhynhzy");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 1, and line: "BCDEF"
     */
    public static void testDecryptLine5() {
        String id = "1, \"BCDEF\"";
        String desc = "Cipher.decryptLine(1, \"BCDEF\");";
        String expected = "ABCDE";
        String actual = "" + Cipher.decryptLine(1, "BCDEF");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing decryptLine with shift of 25, and line: "ZABCD"
     */
    public static void testDecryptLine6() {
        String id = "25, \"ZABCD\"";
        String desc = "Cipher.decryptLine(25, \"ZABCD\");";
        String expected = "ABCDE";
        String actual = "" + Cipher.decryptLine(25, "ZABCD");
        testResult(id, desc, expected, actual);
    }
    
    /**
     * Testing Invalid shift amount passed to encryptLine method
     */
    public static void testEncryptLineInvalid() {
        String id = "Invalid encryptLine shift amount:  26";
        String desc = "Cipher.encryptLine(26, \"xxx\");";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            actual = "" + Cipher.encryptLine(26, "xxx");
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);
    }
    
    
    /**
     * Testing Invalid shift amount passed to decryptLine method
     */
    public static void testDecryptLineInvalid() {
        String id = "Invalid decryptLine shift amount:  28";
        String desc = "Cipher.decryptLine(28, \"xxx\");";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            actual = "" + Cipher.decryptLine(28, "xxx");
        } catch (IllegalArgumentException e) {
            actual = "" + e.getClass();
        }
        testResult(id, desc, expected, actual);
    }
    
    
    /**
     * Testing Invalid shift amount passed to processFile method
     */
    public static void testProcessFileInvalid() {
        String id = "Invalid processFile shift amount:  0";
        String desc = "Cipher.processFile(0, true, null, null);";
        String expected = "class java.lang.IllegalArgumentException";
        String actual = "";
        try {
            Cipher.processFile(0, true, null, null);
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
  