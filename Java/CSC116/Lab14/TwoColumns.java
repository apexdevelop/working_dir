import java.io.*;
import java.util.*;

/**
 * Calculate average number of each column
 * 
 * @author Yan Chen
 */
public class TwoColumns {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        processFile();
    }

    /**
     * read the file
     */
    public static void processFile() {
        Scanner console = new Scanner(System.in);
        Scanner fileScanner = getInputScanner(console);
        double sum1=0.0;
        double sum2=0.0;
        int countLine=0;
        while (fileScanner.hasNextLine()) {
            String line = fileScanner.nextLine();
            countLine+=1;
            Scanner lineScan = new Scanner(line);
            while (lineScan.hasNext()) {
                double f1 = lineScan.nextDouble();
                sum1+=f1;
                double f2 = lineScan.nextDouble();
                sum2+=f2;
            }
        }
        
        double avg1 = sum1/(double)countLine;
        double avg2 = sum2/(double)countLine;
        
        System.out.println(avg1 + " " + avg2);
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