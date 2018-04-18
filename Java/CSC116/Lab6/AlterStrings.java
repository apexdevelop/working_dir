import java.util.Scanner;

/**
 * Read strings from user and reverse the order
 *@author Yan Chen
 */
 public class AlterStrings {
     /**
      * Starts the program.
      * @param args command line arguments
      */
      public static void main(String[] args) {
          // Set up Scanner for console
          Scanner in = new Scanner(System.in);
          //Prompt for input of string
          System.out.print ("Please enter your full name:");
          String name = in.nextLine();
          // print in reverse order
          int indexofspace=name.indexOf(" ");
          String first = name.substring(0,indexofspace);
          String last = name.substring(indexofspace + 1,name.length());
          System.out.print("Your name in reverse order is " + last + ", ");
          System.out.print(first + "\n");
      }
 }