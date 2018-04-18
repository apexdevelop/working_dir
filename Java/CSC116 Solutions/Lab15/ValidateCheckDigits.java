import java.io.*;
import java.util.*;

/**
 * Program that takes a file of 6-digit account numbers, validates them
 * and writes the valid one to a VALID_ file.
 * 
 * @author Michelle Glatz
 */
public class ValidateCheckDigits {

    /**
     * Starts the program
     * 
     * @param args An array of command line arguments (not used)
     */
    public static void main(String[] args) {
        userInterface();
    }

    
    /**
     * Program's user interface.
     */
    public static void userInterface() {
        // Create null objects as placeholders for scope
        // We specifically want a File object since we are basing the
        // output file's name on the input file's name
        File file = null;
        Scanner inputFile = null;

        Scanner console = new Scanner(System.in);

        // While we have not gotten a valid file that can make a Scanner
        // we'll get an input file, and try to create a Scanner.
        while (inputFile == null) {
            file = getInputFile(console);
            inputFile = getInputScanner(file);
        }

        PrintStream outputFile = getOutputPrintStream(console, file);

        // If the PrintStream could be created, then process the
        // Java file.
        if (outputFile != null) {
            processAcctNumFile(inputFile, outputFile);
            outputFile.close();
        } 
        inputFile.close();
    }

    /**
     * Returns a File object from the file name entered by the user
     * 
     * @param console scanner for the console to read from user
     * @return a File representing the file on the OS entered by the user
     */
    public static File getInputFile(Scanner console) {
        File file = null;
        while (file == null) {
            System.out.println("Account Number File?");
            String name = console.nextLine();
            file = new File(name);
            if (file.exists()) {
                return file;
            }
        }
        return file;
    }

    /**
     * Returns a Scanner for the specified file, or null if the file does not
     * exist.
     *     
     * @param file the File entered by the user
     * @return a Scanner to read the file
     */
    public static Scanner getInputScanner(File file) {
        Scanner inputFile = null;
        try {
            inputFile = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.println("File Not Found. Please try again.");
        }
        return inputFile;
    }
    
    /**
     * Returns a PrintStream for the specified file, or null if the file cannot
     * be created. Output filename should formatted as VALID_inputFileName.java
     * based on name of file. If output file exist, asks user if they wish
     * to overwrite the file. If not, the program will exit.
     * 
     * @param console scanner for the console to read from user      
     * @param inputFile the File oject associated with the input file
     * @return a PrintStream to print to the output file.
     */
    public static PrintStream getOutputPrintStream(Scanner console, File inputFile) {
        PrintStream output = null;
        String inputFileName = inputFile.getName();
        String outputFileName = "VALID_" + inputFileName;
        File outputFile = new File(outputFileName);
        if(outputFile.exists()) {
            System.out.print("OK to overwrite file? (y/n): ");
            String overwrite = console.next();
            if (overwrite.equals("n")) {  
                System.exit(1);                           
            }
        }  
        try {
            output = new PrintStream(outputFile);
        } catch (FileNotFoundException e) {
            System.out.println("File unable to be written.");
        }        
        return output;
    }
    
     /** 
     * Reads in account numbers from input file, determine if they are
     * valid and prints the number and "is valid" or "is NOT valid"
     * to the console. If the number is valid it is written
     * to an output file (one valid account nuumber per line).
     *
     * @param fileScanner a scanner for input file.
     * @param output a PrintStream for writing a file.
     */
    public static void processAcctNumFile(Scanner fileScanner, PrintStream output) {
        while(fileScanner.hasNextInt()) {
            int acctNum = fileScanner.nextInt();
            int digitOne = acctNum % 10;
            int digitTwo = acctNum/10 % 10;
            System.out.println(digitTwo);
            int digitThree = acctNum/100 % 10;
            int digitFour = acctNum/1000 % 10;
            int digitFive = acctNum/10000 % 10;
            int digitSix = acctNum/100000 % 10;            
            if ((digitSix + digitFive + digitFour + digitThree + digitTwo) % 10 
                == digitOne) {
                System.out.println(acctNum + " is valid.");
                output.println(acctNum);
            } 
            else {
                System.out.println(acctNum + " is NOT valid.");
            }
        }
    }   
 
} 
    
           