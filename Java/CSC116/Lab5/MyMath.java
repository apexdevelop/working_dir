/**
 * Our Math class provides methods that return the min and max of three values
 * 
 * @author Yan Chen
 */
public class MyMath {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        System.out.println(min(5, 6, 7)); // EXPECTED OUTPUT: 5.0
        System.out.println(min(20, 25, 15));// EXPECTED OUTPUT: 15.0
        System.out.println(min(77.7, 11.1, 33.3));// EXPECTED OUTPUT: 11.1
        System.out.println(max(5, 6, 7)); // EXPECTED OUTPUT: 7.0
        System.out.println(max(20, 25, 15));// EXPECTED OUTPUT: 25.0
        System.out.println(max(77.7, 11.1, 33.3));// EXPECTED OUTPUT: 77.7
        System.out.println(average(1, 2, 3));// EXPECTED OUTPUT: 2.0
        System.out.println(average(100.0, 98.8, 77.3));// EXPECTED OUTPUT:
                                                       // 92.0333333333333
                                                       // (possibly different
                                                       // based on quirks of
                                                       // doubles)
        System.out.println(average(-9, 3, 9));// EXPECTED OUTPUT: 1.0
    }

    /**
     * Returns the smallest parameter
     * 
     * @param a
     *            first double in comparison
     * @param b
     *            second double in comparison
     * @param c
     *            third double in comparison
     * @return minimum of a, b, c
     */
    public static double min(double a, double b, double c) {
        // TODO: Finish method. HINT: Use Math.min multiple times.
        double min_num;
        min_num=Math.min(a,b);
        min_num=Math.min(min_num,c);
        return min_num;
    }

    /**
     * Returns the largest parameter
     * 
     * @param a
     *            first double in comparison
     * @param b
     *            second double in comparison
     * @param c
     *            third double in comparison
     * @return maximum of a, b, c
     */
    public static double max(double a, double b, double c) {
        // TODO: Finish method. HINT: Use Math.max multiple times.
        double max_num;
        max_num=Math.max(a,b);
        max_num=Math.max(max_num,c);
        return max_num;
    }

    /**
     * Returns the average of the three parameters
     * 
     * @param a
     *            first double in average
     * @param b
     *            second double in average
     * @param c
     *            third double in average
     * @return average of a, b, c
     */
    public static double average(double a, double b, double c) {
        // TODO: Finish method.
        double average_num;
        average_num=(a + b + c)/ 3.0;
        return average_num;
    }
}
