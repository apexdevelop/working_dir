import java.util.Scanner;

/**
 * Read integers from user and calculate sum, average, max, min
 * @author Yan Chen
 */
 public class MathOnUserInput {
     /**
      * Starts the program.
      * @param args command line
      */
      public static void main(String[] args) {
          // Set up Scanner for console
          Scanner in = new Scanner(System.in);
          // Prompt for number of integers and read in value
          System.out.print(" How many integers? ");
          int numInts = in.nextInt();
          //Declare and initialize sum, average, max, min
          int sum = 0;
          double average = 0.0;
          int max = Integer.MIN_VALUE;
          int min = Integer.MAX_VALUE;
          // Read in integers
          for (int i = 0; i < numInts; i++) {
              System.out.print("Next Integer? ");
              int temp = in.nextInt();
              sum += temp;
              min = Math.min(min, temp);
              max = Math.max(max, temp);
          }
          average = (double)sum/numInts;
          //Print sum
          System.out.println("Sum = " + sum);
          System.out.println("Average = " + average);
          System.out.println("Min = " + min);
          System.out.println("Max = " + max);
      }
 }