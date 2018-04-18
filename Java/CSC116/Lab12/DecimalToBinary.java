/**
 * Program to convert decimals to binarys
 * 
 * @author Yan Chen
 */

import java.util.Scanner;
public class DecimalToBinary {

   public static String convertToBinary(int n) {
       if (n == 0) {
           return "0";
       }
       
       if ( n<0 && n != -1) {
           throw new IllegalArgumentException("n must be positive");
       }
       
       String binary = "";
       while (n > 0) {
           int rem = n % 2;
           binary = rem + binary;
           n = n / 2;
       }
       return binary;
   }

   public static void main(String[] args) {
       String binary;
       int decimal;
       Scanner in = new Scanner(System.in);
       do {       
           System.out.print("Enter a number ( -1 to quit) : ");
           while (!in.hasNextInt()) {
               in.next(); // discard input
               System.out.print("Not an int; try again: ");
           }
           decimal = in.nextInt();
           // ASSERT: number is integer 
           while (decimal < 0 && decimal !=-1) {
               //while (!in.hasNextInt()) {
               //    in.next(); // discard input
               //    System.out.print("Not an int; try again: ");
               //}
               System.out.print("That is negative; try again: ");
               decimal = in.nextInt();               
           }
           
           // ASSERT: number is non-negative
           binary = convertToBinary(decimal);
           System.out.println("The binary representation is " + binary);         
       } while (decimal != -1);

   }
}
