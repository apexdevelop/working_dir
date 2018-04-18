/**
 * calculate squares
 *
 *@author Yan Chen
 */
public class Squares {
    /**
     * Starts the program.
     *
     *@param args
     *           command line arguments
     */
    public static void main(String[] args) {
        int x = 1;
        int a = 3;
        int d = 2;
        for (int i = 1; i <= 10; i++) {
            System.out.print(x + " ");
            x = x + a;
            a = a + d;
        }
        System.out.println();
    }
}