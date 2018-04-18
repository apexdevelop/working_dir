import java.io.*;
import java.util.*;
/**
 * Program encrypt and decrypt codes suing cipher methods
 * @author Yan Chen
 */
public class Cipher {
    public static void main(String[] args) throws FileNotFoundException  {
        Scanner console = new Scanner(System.in);
        
        int nShift = getShiftAmount(console);
        Scanner input = getInputScanner(console);
        PrintStream output= getOutputPrintStream(console);
        
        String choice ="";
        do{
            System.out.print("Would you like to (E)ncrypt or (D)ecrypt a message? Or (Q)uit? ");
            choice = console.next();
            boolean encrypt;
            if (choice.equals("E") || choice.equals("e")){
                encrypt=true;
                processFile (nShift, encrypt, input, output);
            } else if (choice.equals("D") || choice.equals("d")) {
                encrypt=false;
                processFile (nShift, encrypt, input, output);
            } else if (choice.equals("Q") || choice.equals("q")) {
                System.exit(1);
            } else {
                System.out.println("Invalid action. Please try again.");
            }
        } while (!choice.equals("E") && !choice.equals("e") && !choice.equals("D") && !choice.equals("d") && !choice.equals("Q") && !choice.equals("q"));
        //processFile (nShift, encrypt, input, output);
        
    }
    
    /*
     * Prompts the user for and returns a valid shift amount for encryption/decryption.
     * @param: Scanner console
     * @return: int
     */
    public static int getShiftAmount(Scanner console) {
        int shiftAmount = 0;
        do{
            System.out.print("Shift amount (1 - 25)? ");        
            while(!console.hasNextInt()){
                console.next(); // discard input
                System.out.println("Invalid shift amount. Please try again.");            
                System.out.print("Shift amount (1 - 25)? ");            
            }
            // ASSERT: shiftAmount is integer 
            shiftAmount=console.nextInt();
            if (shiftAmount<1 || shiftAmount>25) {
                System.out.println("Invalid shift amount. Please try again."); 
            }
        } while (shiftAmount<1 || shiftAmount>25); 
        return shiftAmount; 
    }
    
    /**
     * using code from class
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * 
     * @return a scanner to read input from the file
     * @throws FileNotFoundException if File does not exist
     */
      
    public static Scanner getInputScanner(Scanner console) {
        Scanner fileScanner = null;
        
        while (fileScanner == null) {
            try {
             System.out.print("Input filename? ");
             File file = new File(console.next());
             fileScanner = new Scanner(file);      
            
            } catch (FileNotFoundException e) {
                System.out.println("Error reading file: " + e);                
            } 
        }        
        return fileScanner;
        
    }
    
    
    /*Prompts the user for the name of an output file. 
    *If the file does not exist, creates and returns a PrintStream for the output file.
    *If the file does exist, prints an error message and exits the program OR
    *does one of the Extra Credit options described below.
    *Use a try/catch block to catch and handle any FileNotFoundException's that occur
    */
    public static PrintStream getOutputPrintStream(Scanner console) {
        PrintStream output = null;
        while (output == null) {
            try{
                System.out.print("Output filename? ");
                String filename = console.next();
                File file = new File(filename); 
                if (file.exists()) {
                    System.out.print("OK to overwrite file? (y/n): ");
                    String choice = console.next();
                    if (choice.equals("n")) {
                        System.out.print("Output filename? ");
                        filename = console.next();
                        file = new File(filename);
                    }
                }
                output = new PrintStream(file);
            } catch (FileNotFoundException e){
                System.out.println("Error reading file: " + e); 
            }
        }
        return output;
    }
    
    /*If encrypt is true, encrypts message in input and outputs encrypted message
     *If encrypt is false, decrypts message in input and outputs decrypted message
     *Throw an IllegalArgumentException if the shiftAmount is less than 1 or greater than 25
     */
    public static void processFile (int shiftAmount, boolean encrypt, Scanner input, PrintStream output){
       String outString="";      
       if (shiftAmount < 1 || shiftAmount > 25) {
            throw new IllegalArgumentException("invalid shiftAmount");
       } 
       if (input ==null ) {
            throw new IllegalArgumentException("null input");
       } 
       if (output ==null ) {
            throw new IllegalArgumentException("null output");
       } 
       while (input.hasNextLine()) {
            //String line = input.nextLine(); 
            String inString = input.nextLine();
            if (encrypt){
                outString=encryptLine(shiftAmount,inString);
           } else {
                outString=decryptLine(shiftAmount,inString);
           }
           output.println(outString);
           //output.close();
       }   
    }
    
    /*
     * Returns string containing line encrypted using shift amount
     * Throw an IllegalArgumentException if the shiftAmount is less than 1 or greater than 25
     * @param: shiftAmount
     * @param: line
     * @return: retString
     */
    public static String encryptLine(int shiftAmount, String line){
        char a;
        char b;
        int disLower;
        int disUpper;
        String retString="";
        
        if (shiftAmount < 1 || shiftAmount > 25) {
            throw new IllegalArgumentException("invalid shiftAmount");
        } else {
            for (int i =0;i<line.length();i++) {
                a = line.charAt(i);
                if (Character.isLowerCase(a)){
                    disLower = 'z' - a;
                    if (disLower>=shiftAmount) {
                       b = (char) (a+shiftAmount);
                    } else {
                       b = (char) ('a'+shiftAmount-disLower-1);
                    }
                } else if (Character.isUpperCase(a)){
                    disUpper = 'Z' - a;
                    if (disUpper>=shiftAmount) {
                       b = (char) (a+shiftAmount);
                    } else {
                       b = (char) ('A'+shiftAmount-disUpper-1);
                    }   
                } else {
                    b = a;
                }
                retString+=b;            
            }
        }
        return retString;
    }

   /*
     * Returns string containing line decrypted using shift amount
     * Throw an IllegalArgumentException if the shiftAmount is less than 1 or greater than 25
     * @param: shiftAmount
     * @param: line
     * @return: retString
     */
    public static String decryptLine(int shiftAmount, String line){
        char a;
        char b;
        int disLower;
        int disUpper;
        String retString="";
        
        if (shiftAmount < 1 || shiftAmount > 25) {
            throw new IllegalArgumentException("invalid shiftAmount");
        } else {
            for (int i =0;i<line.length();i++) {
                a = line.charAt(i);
                if (Character.isLowerCase(a)){
                    disLower = a - 'a';
                    if (disLower>=shiftAmount) {
                       b = (char) (a-shiftAmount);
                    } else {
                       b = (char) ('z'-(shiftAmount-disLower-1));
                    }
                } else if (Character.isUpperCase(a)){
                    disUpper = a-'A';
                    if (disUpper>=shiftAmount) {
                       b = (char) (a-shiftAmount);
                    } else {
                       b = (char) ('Z'-(shiftAmount-disUpper-1));
                    }   
                } else {
                    b = a;
                }
                retString+=b;            
            }
        }
        return retString;
    }


}