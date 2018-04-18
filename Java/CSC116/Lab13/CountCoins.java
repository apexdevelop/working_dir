import java.util.*;
import java.io.*;

/**
 * Program reads in a file and count coins
 * @author Yan Chen
 */
public class CountCoins {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) throws FileNotFoundException {
        userInterface();
    }

    /**
     * Interface with the user
     */
    public static void userInterface() throws FileNotFoundException {
        Scanner console = new Scanner(System.in);
        Scanner fileScanner = getInputScanner(console);
        
        // need to declare (and initalize) variables
        double sum=0.0;
        int new_int;
        String new_string;
        // process file
        // only want to examine the integers in the file
        while (fileScanner.hasNext()) {
               new_int = fileScanner.nextInt();
               new_string=fileScanner.next();
               new_string=new_string.toLowerCase();
             if (new_string.equals("pennies")) {
                 sum+=new_int*0.01;
             } else if (new_string.equals("nickels")) {
                 sum+=new_int*0.05;
             } else if (new_string.equals("dimes")) {
                 sum+=new_int*0.10;
             } else  {
                 sum+=new_int*0.25;
             }
        }
        fileScanner.close();
        System.out.format("Total money: $%.2f%n" ,sum);
    }

    /**
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * 
     * @return a scanner to read input from the file
     * @throws FileNotFoundException if File does not exist
     */
    public static Scanner getInputScanner(Scanner console) throws FileNotFoundException {
        System.out.print("Enter a file name to process: ");
        File file = new File(console.next());
        while (!file.exists()) {
            System.out.print("File doesn't exist. " + "Enter a file name to process: ");
            file = new File(console.next());
        }

        Scanner fileScanner = new Scanner(file);
        return fileScanner;
    }
}