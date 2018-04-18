import java.util.*;

/**
 * A program that converts decimal numbers to their binary equivalent until the
 * user types -1 to quit
 * 
 * @author Dr. Sarah Heckman (sarah_heckman@ncsu.edu)
 * @author Dr. Jessica Young Schmidt
 */
public class DecimalToBinary {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        userInterface();
    }

    /**
     * Interface with the user that reads in numbers and prints out their binary
     * equivalent
     */
    public static void userInterface() {
        System.out.println("This program converts nonnegative decimal numbers "
                        + "(integers) to their binary equivalent until the user types"
                        + " -1 to quit\n");
        Scanner console = new Scanner(System.in);
        int input = 0;
        do {
            System.out.print("Enter a number (-1 to quit): ");
            while (!console.hasNextInt()) {
                console.next();
                System.out.println("Not an int, try again");
                System.out.print("Enter a number (-1 to quit): ");
            }
            input = console.nextInt();
            if (input > -1) {
                String binary = convertToBinary(input);
                System.out.println("Decimal: " + input + ", Binary: " + binary);
            } else if (input < -1) {
                System.out.println("Need a nonnegative number or -1 to quit");
            }
        } while (input != -1);
    }

    /**
     * Converts a decimal number to binary
     * 
     * @param decimal number to convert
     * @return binary string of number
     * @throws IllegalArgumentException if decimal < 0
     */
    public static String convertToBinary(int decimal) {
        // Pre-condition: non-negative. Throwing an exception was not listed as
        // a requirement in the assignment. NOTE: Our userInterface() method
        // should never call convertToBinary if the value is negative.
        if (decimal < 0) {
            throw new IllegalArgumentException("Negative value");
        }
        String binary = "";
        if (decimal == 0) { // Special case
            return "0";
        }
        while (decimal != 0) {
            binary = (decimal % 2) + binary;
            decimal /= 2;
        }
        return binary;
    }
}