import java.io.*;
import java.util.*;

/**
 * Flips the order of pairs of lines
 * 
 * @author Jessica Young Schmidt
 * @author Yan Chen
 */
public class FlipLines {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        userInterface();
    }

    /**
     * Interface with the user
     */
    public static void userInterface() {
        Scanner console = new Scanner(System.in);
        Scanner fileScanner = getInputScanner(console);
        flipLines(fileScanner);
    }

    /**
     * Flips the order of pairs of lines in input. If the file contains an odd
     * number of lines, leave the last line unmodified.
     * 
     * @param input Scanner for the input file
     */
    public static void flipLines(Scanner input) {
        String line1 = null;
        while (input.hasNextLine()) {
            line1 = input.nextLine();
            if (input.hasNextLine()) {
                String line2 = input.nextLine();
                System.out.println(line2);
                System.out.println(line1);
                line1 = null;
            } else {
                System.out.println(line1);
            }
        }
    }

    /**
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * 
     * @return a scanner to read input from the file
     */
    public static Scanner getInputScanner(Scanner console) {
        System.out.print("Enter a file name to process: ");
        File file = new File(console.next());
        while (!file.exists()) {
            System.out.print("File doesn't exist. " + "Enter a file name to process: ");
            file = new File(console.next());
        }
        Scanner fileScanner = null;// null signifies NO object reference
                                   // while (result == null) {
        try {
            fileScanner = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.println("Input file not found. ");
            System.out.println(e.getMessage());
            System.exit(1);
        }
        return fileScanner;
    }

}