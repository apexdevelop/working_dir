import java.util.Arrays;

/**
 * Write a method called allLess that accepts two arrays of integers and returns
 * true if each element in the first array is less than the element at the same
 * index in the second array. If the arrays are not the same length, your method
 * should return false.
 * 
 * @author Yan Chen
 */
public class AllItemsLess {
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

        int[] arr1 = { 1, 2, 3 };
        int[] arr2 = { 4, 5, 6 };
        testResult(arr1, arr2, true);

        int[] arr3 = { 45, 20, 300 };
        int[] arr4 = { 50, 41, 600 };
        testResult(arr3, arr4, true);

        int[] arr5 = { 67, 11, 98, -4 };
        int[] arr6 = { 50, 41, 600, 1 };
        testResult(arr5, arr6, false);

        int[] arr7 = { 45, 20, 300 };
        int[] arr8 = { 50, 41, 600, 12 };
        testResult(arr7, arr8, false);
        System.out.printf("\n\n%4d / %4d passing tests\n", passingTestCounter, testCounter);
    }

    /**
     * Prints result from running method
     * 
     * @param arr1 first array to compare
     * @param arr2 second array to compare
     * @param exp expected result of running method
     */
    private static void testResult(int[] arr1, int[] arr2, boolean exp) {
        testCounter++;
        String result = FAIL;
        boolean act = allLess(arr1, arr2);
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-20s%-20s%-6s%-10s%-10s\n", Arrays.toString(arr1),
                        Arrays.toString(arr2), result, exp, act);
    }

    /**
     * accepts two arrays of integers and returns true if each element in the
     * first array is less than the element at the same index in the second
     * array. Your method should return false if the arrays are not the same
     * length.
     * 
     * @param arr1 first array to compare
     * @param arr2
     * @return true if elements in first array are less than elements in second
     *         array at each index, else false
     */
    public static boolean allLess(int[] arr1, int[] arr2) {
        if (arr1.length != arr2.length) {
            return false; // if the two arrays are NOT the same    length then we
                          // know that they are not equal so we can return
                          // false and end method
        }
        // ASSERT: each element in array1 is less than element in array2
        for (int i = 0; i < arr1.length; i++) {
            if (arr1[i] >= arr2[i]) {
                return false;
            }
       }
       // ASSERT: array1 and array2 contain the same number of elements AND the
       // each element of the array1 is less than element in array2
        return true;
    }
}