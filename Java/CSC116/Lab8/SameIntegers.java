import java.util.Scanner;

/**
 * compare three integers
 * @author Yan Chen
 */
 
 public class SameIntegers{       
       public static void main(String[] args) {
           // Set up Scanner for console
           Scanner in = new Scanner(System.in);
           // Prompt for entering three integers
           System.out.print("Enter three integers: ");
           int a = in.nextInt();
           int b = in.nextInt();
           int c = in.nextInt();
           if (a==b && a==c) {
               System.out.println("all the same");
           } else if (a!=b && a!=c && b!=c) {
               System.out.println("all different");
           } else {
               System.out.println("neither");
           }
       }
 }