import java.util.Scanner;

/**
 * check password entered from the console
 *@author Yan Chen
 */
 public class ValidatePassword {
     /**
      * Starts the program.
      * @param args command line arguments
      */
      public static void main(String[] args) {
          // Set up Scanner for console
          Scanner in = new Scanner(System.in);
          //Prompt for input of string
          
          //String password = "";
          
          System.out.print ("Enter your password, which must contains no whitespace and at least two uppercase letters, at least two lowercase letters, and at least two digits:");
          String password = in.nextLine();
          
          //String password = "HHhh";
          
          //count number of uppercase, lowercase and digits
          int length=password.length();
          int countU=0;
          int countL=0;
          int countD=0;
          
          for (int i = 0; i<length; i++) {
              if (Character.isUpperCase(password.charAt(i))) {
                  countU+=1;
              }
              if (Character.isLowerCase(password.charAt(i))) {
                  countL+=1;
              }
              if (Character.isDigit(password.charAt(i))) {
                  countD+=1;
              }
          }
          
          if (countU>=2 && countL>=2 && countD>=2) {
              System.out.println("Your password (" + password + ") is valid.");
          } else {
              System.out.println("Your password (" + password + ") is invalid because:");
              if (countU<2) {
                  System.out.println("- fewer than two uppercase letters");
              }
              if (countL<2) {
                  System.out.println("- fewer than two lowercase letters");
              }
              if (countD<2) {
                  System.out.println("- fewer than two digits");
              }
          }  
      }
 }