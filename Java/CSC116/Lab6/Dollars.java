import java.util.Scanner;

/**
 * Convert dollars into currency denominations repeated until enters -1
 * @author Yan Chen
 */
 
 public class Dollars{
       
       public static void main(String[] args) {
       // Set up Scanner for console
       Scanner in = new Scanner(System.in);
       int dollar=0;
       int n_20;
       int n_10;
       int n_5;
       int n_1;
       
       while (dollar!=-1) {
       // Prompt for dollar and read in value
           System.out.print("Enter dollar Amount: ");
           while (!in.hasNextInt()) {             
               in.next(); // discard input
               System.out.print("Not an int; try again: ");
               // ASSERT: number is integer 
           }
           dollar = in.nextInt();

           if ( dollar<=0 && dollar != -1) {
              System.out.print("Invalid; try again: ");
              // ASSERT: number is positive
              dollar = in.nextInt();
           }
           
           n_20 = dollar / 20;
           n_10 = (dollar - n_20 * 20) / 10;
           n_5 = (dollar - n_20 * 20 - n_10 * 10) / 5;
           n_1 = (dollar - n_20 * 20 - n_10 * 10 - n_5 * 5);
           if (dollar!=-1) {
           System.out.println("$" + dollar + " converts to: " + n_20 + " 20s, " + n_10 + " 10s, " + n_5 + " 5s, and " + n_1 + " 1s.");
           }
       }
       
       }
       
 }