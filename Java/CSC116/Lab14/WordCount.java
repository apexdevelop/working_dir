import java.io.*;
import java.util.*;

/**
 * count number of lines, words and chars in a file
 * 
 * @author Yan Chen
 */
public class WordCount {

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
        int countL=0;
        int countW=0;
        int countC=0;
        while (fileScanner.hasNextLine()) {
            String line = fileScanner.nextLine();
            countL+=1;
            Scanner lineScan = new Scanner(line);
            while (lineScan.hasNext()) {
                String word = lineScan.next();
                countW+=1;
                countC+=word.length();
            }
        }        
        System.out.println("Total lines = " + countL);
        System.out.println("Total words = " + countW);
        System.out.println("Total chars = " + countC);
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