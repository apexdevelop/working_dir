import java.util.Scanner;

/**
 * tell if an integer is even or odd
 * @author Yan Chen
 */
 
 public class EvenOdd{       
       public static void main(String[] args) {
           // Set up Scanner for console
           Scanner in = new Scanner(System.in);
           // Prompt for entering an integer
           System.out.print("Enter an integer: ");
           int a = in.nextInt();
           int q = a % 2;
           if (q==0) {
               System.out.println(a + " is even");
           } else {
               System.out.println(a + " is odd");
           }
       }
 }