import java.util.*;
import java.io.*;

/**
 * Program reads in a file and find the max, min, sum count, and average of all
 * integers in the file
 * 
 * @author Dr. Sarah Heckman (sarah_heckman@ncsu.edu)
 * @author Dr. Jessica Young Schmidt
 */
public class ProcessFile {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     * @throws FileNotFoundException if file cannot be found
     */
    public static void main(String[] args) throws FileNotFoundException {
        userInterface();
    }

    /**
     * Interface with the user
     * 
     * @throws FileNotFoundException if file cannot be found
     */
    public static void userInterface() throws FileNotFoundException {
        Scanner console = new Scanner(System.in);
        Scanner fileScanner = getInputScanner(console);

        int max = Integer.MIN_VALUE;
        int min = Integer.MAX_VALUE;
        int sum = 0;
        int count = 0;
        double average = 0.0;
        while (fileScanner.hasNext()) {
            if (fileScanner.hasNextInt()) {
                int n = fileScanner.nextInt();
                if (n > max) {
                    max = n;
                }
                if (n < min) {
                    min = n;
                }
                sum += n;
                count++;
            } else {
                fileScanner.next();// throw away input
            }
        }
        average = sum / (double) count;
        System.out.println("Maximum = " + max);
        System.out.println("Minimum = " + min);
        System.out.println("Sum = " + sum);
        System.out.println("Count = " + count);
        System.out.println("Averge = " + average);
    }

    /**
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * @return a scanner to read input from the file
     * @throws FileNotFoundException if file cannot be found
     */
    public static Scanner getInputScanner(Scanner console) throws FileNotFoundException {
        System.out.print("Enter a file name to process: ");
        File file = new File(console.next());
        while (!file.exists()) {
            System.out.print("File doesn't exist. Enter a file name to process: ");
            file = new File(console.next());
        }

        Scanner fileScanner = new Scanner(file);
        return fileScanner;
    }
}