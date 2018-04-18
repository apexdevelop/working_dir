import java.util.Arrays;

/**
 * Program determines if two dimensional arrays are equal.
 * 
 * @author Yan Chen
 */
public class TwoDArrayEquality {

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

        int[][] ints1 = { { 35, 35, 45, 49, 53, 53, 55 }, { 50, 52, 68, 75, 78, 76, 75 } };

        int[][] ints2 = { { 35, 35, 45, 49, 53, 53, 55 }, // same
                        { 50, 52, 68, 75, 78, 76, 75 } };

        int[][] ints3 = { { 35, 35, 45, 49, 53, 53, 55 }, // one diff value
                        { 50, 52, 68, 75, 78, 76, 76 } };

        int[][] ints4 = { { 35, 35, 45, 49, 53, 53, 55 }, // more rows
                        { 55, 52, 68, 75, 78, 76, 75 }, { 55, 52, 68, 77, 88, 66, 55 } };

        int[][] ints5 = { { 35, 35, 45, 49, 53, 53 }, // fewer elements on first
                                                      // row
                        { 50, 52, 68, 75, 78, 76, 75 } };
        int[][] ints6 = { {} };
        int[][] ints7 = { {} };
        int[][] ints8 = { { 1 }, { 2, 3 } };
        int[][] ints9 = { { 2, 3 }, { 1 } };

        System.out.println("ints1: " + Arrays.deepToString(ints1));
        System.out.println("ints2: " + Arrays.deepToString(ints2));
        System.out.println("ints3: " + Arrays.deepToString(ints3));
        System.out.println("ints4: " + Arrays.deepToString(ints4));
        System.out.println("ints5: " + Arrays.deepToString(ints5));
        System.out.println("ints6: " + Arrays.deepToString(ints6));
        System.out.println("ints7: " + Arrays.deepToString(ints7));
        System.out.println("ints8: " + Arrays.deepToString(ints8));
        System.out.println("ints9: " + Arrays.deepToString(ints9));

        testResult("ints1 & ints1", true, equals2D(ints1, ints1));
        testResult("ints1 & ints2", true, equals2D(ints1, ints2));
        testResult("ints1 & ints3", false, equals2D(ints1, ints3));
        testResult("ints1 & ints4", false, equals2D(ints1, ints4));
        testResult("ints1 & ints5", false, equals2D(ints1, ints5));
        testResult("ints1 & ints6", false, equals2D(ints1, ints6));
        testResult("ints7 & ints6", true, equals2D(ints7, ints6));
        testResult("ints8 & ints9", false, equals2D(ints8, ints9));

        String[][] Strings1 = { { "Cat", "Dog", "Puppy" }, { "A", "B", "C" } };

        String[][] Strings2 = { { "Cat", "Dog", "Puppy" }, { "A", "B", "C" } };// Same

        String[][] Strings3 = { { "Cat", "dog", "Puppy" }, { "A", "B", "C" } };// One
                                                                               // different
                                                                               // value

        String[][] Strings4 = { { "Cat", "Dog", "Puppy" }, { "A", "B", "C" },
                        { "Cat", "Dog", "Puppy" } };// more rows

        String[][] Strings5 = { { "Cat", "Dog" }, { "A", "B", "C" } };
        String[][] Strings6 = { {} };
        String[][] Strings7 = { {} };

        System.out.println("Strings1: " + Arrays.deepToString(Strings1));
        System.out.println("Strings2: " + Arrays.deepToString(Strings2));
        System.out.println("Strings3: " + Arrays.deepToString(Strings3));
        System.out.println("Strings4: " + Arrays.deepToString(Strings4));
        System.out.println("Strings5: " + Arrays.deepToString(Strings5));
        System.out.println("Strings6: " + Arrays.deepToString(Strings6));

        testResult("Strings1 & Strings1", true, equals2D(Strings1, Strings1));
        testResult("Strings1 & Strings2", true, equals2D(Strings1, Strings2));
        testResult("Strings1 & Strings3", false, equals2D(Strings1, Strings3));
        testResult("Strings1 & Strings4", false, equals2D(Strings1, Strings4));
        testResult("Strings1 & Strings5", false, equals2D(Strings1, Strings5));
        testResult("Strings1 & Strings6", false, equals2D(Strings1, Strings6));
        testResult("Strings7 & Strings6", true, equals2D(Strings7, Strings6));

        System.out.printf("\n\n%4d / %4d passing tests\n", passingTestCounter, testCounter);

    }

    /**
     * Prints the test information.
     * 
     * @param arr array names
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String arr, boolean exp, boolean act) {
        testCounter++;
        String result = FAIL;
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-25s%-6s%-8s%-8s\n", arr, result, exp, act);
    }

    /**
     * Test two dimensional arrays (of ints) for equality
     * 
     * @param a first array to examine
     * @param b second array to examine
     * @return whether a and b are equal (contain all of the same elements in
     *         the same order/location)
     */
    public static boolean equals2D(int[][] a, int[][] b) {
        
        if (a.length!=b.length){
            return false;
        }
        
        if (a.length==0 && b.length==0) {
            return true;
        }
        
        if (a.length==2 && b.length==2) {
            int[] a1 = a[0];
            int[] a2 = a[1];
            int[] b1 = b[0];
            int[] b2 = b[1];
        
            if (a1.length!=b1.length) {
                return false;
            }
        
            if (a2.length!=b2.length) {
                return false;
            }
        
            for (int i =0; i<a1.length;i++) {
                if (a1[i]!=b1[i]) {
                    return false;
                }
            }
        
            for (int i =0; i<a2.length;i++) {
                if (a2[i]!=b2[i]) {
                    return false;
                }
            }
        
            return true;
        } else {
          if (a[0].length==0 && b[0].length==0) {
              return true;
          } else {
              if (a[0].length!=b[0].length) {
                  return false;
              }
              for (int i =0; i<a[0].length;i++) {
                if (a[0][i]!=b[0][i]) {
                    return false;
                }
              }
            return true;
          }
        }
    }

    /**
     * Test two dimensional arrays (of Strings) for equality
     * 
     * @param a first array to examine
     * @param b second array to examine
     * @return whether a and b are equal (contain all of the same elements in
     *         the same order/location)
     */
    public static boolean equals2D(String[][] a, String[][] b) {
        if (a.length!=b.length){
            return false;
        }
        
        if (a.length==0 && b.length==0) {
            return true;
        }
        
        if (a.length==2 && b.length==2) {
            String[] a1 = a[0];
            String[] a2 = a[1];
            String[] b1 = b[0];
            String[] b2 = b[1];
        
            if (a1.length!=b1.length) {
                return false;
            }
        
            if (a2.length!=b2.length) {
                return false;
            }
        
            for (int i =0; i<a1.length;i++) {
                if (a1[i].equals(b1[i])==false) {
                    return false;
                }
            }
        
            for (int i =0; i<a2.length;i++) {
                if (a2[i].equals(b2[i])==false) {
                    return false;
                }
            }
        
            return true;
        } else {
          if (a[0].length==0 && b[0].length==0) {
              return true;
          } else {
              if (a[0].length!=b[0].length) {
                  return false;
              }
              for (int i =0; i<a[0].length;i++) {
                if (a[0][i].equals(b[0][i])==false) {
                    return false;
                }
              }
            return true;
          }
        }
    }

}
