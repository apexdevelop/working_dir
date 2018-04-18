import java.util.Scanner;

/**
 * calculate price for eggs repeatedly until enters -1
 * @author Yan Chen
 */
 
 public class Eggs{
       
       public static void main(String[] args) {
       // Set up Scanner for console
       Scanner in = new Scanner(System.in);
       int n_egg=0;
       int n_dozen;
       int n_loose;
       double price;
       
       while (n_egg!=-1) {
       // Prompt for number of eggs and read in value
           System.out.print("Enter number of eggs: ");
           
           while (!in.hasNextInt()) {             
               in.next(); // discard input
               System.out.print("Not an int; try again: ");
               // ASSERT: number is integer 
           }
           n_egg = in.nextInt();

           if ( n_egg<=0 && n_egg != -1) {
              System.out.print("Invalid; try again: ");
              // ASSERT: number is positive
              n_egg = in.nextInt();
           }

           n_dozen=n_egg / 12;
           n_loose=n_egg % 12;
           price=n_dozen*3.25+n_loose*0.45;
           if (n_egg!=-1) {
           System.out.println("You ordered " + n_egg + " eggs. That's " + n_dozen + " dozen at $3.25 per dozen and " + n_loose + " loose eggs at 45 cents each for a total of $" + price);
           }
       }
       
       } 
 }