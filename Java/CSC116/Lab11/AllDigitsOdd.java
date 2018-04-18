import java.util.*;

/**
 * Determines if every digit of an integer is odd
 * @author Yan Chen
 */
public class AllDigitsOdd {
    /**
     * Starts program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        System.out.print("Enter an integer: ");
        int n = in.nextInt();
        boolean result = allDigitsOdd(n);
        System.out.println(result);            
    }
    
    public static boolean allDigitsOdd (int n) {
        boolean result = true;
        int q = 1;  //q is number of the digits of n
        int p = q * 10;
        n = Math.abs(n); // transform into positive number
        while ( n / p > 1) {
           q=q+1;
           p = p * 10;
           //p=Math.pow(10,q);
        }
        
        //calculating number of odd digits
        int p1 = p;
        int r = n; //remaining of n
        int d = 0;
        for (int i = q-1; i>=0; i--) {
           //p1 = Math.pow(10,i);
           p1 = p1/10;
           d = r/p1;
           r = r - p1 * d;
           if ( d % 2 ==0) {
              result = false;
           }
        }
        return result;
    }
}