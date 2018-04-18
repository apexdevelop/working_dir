import java.util.Scanner;

/**
 * Read a and calculate number of coconuts
 * @author Yan Chen
 */
 public class Coconuts {
     /**
      * Starts the program.
      * @param args command line
      */
      public static void main(String[] args) {
          // Set up Scanner for console
          Scanner in = new Scanner(System.in);
          // Prompt for non-negative integer a and read in value
          System.out.print("Enter a non-negative integer a: ");
          int a = in.nextInt();
          //Declare and initialize total number of coconuts;
          int total = 12495 + 15625 * a;
          int numtaken = 0;
          int remain = total;
          // Read in integers
          for (int i = 1; i <= 5; i++) {
              numtaken = (int) (remain /5 ); //each sailor takes 1/5 of the remaining coconuts
              remain -= (numtaken + 1);  //calculate remaining coconuts
              System.out.println("Sailor " + i +": " + numtaken +" coconuts; Monkey: 1 coconut.");
          }
          numtaken = (int) ((remain - 1)/ 5);
          System.out.println(remain + " coconuts remain, each sailor gets " + numtaken + " and 1 for the monkey.");
      }
 }