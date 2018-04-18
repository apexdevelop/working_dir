import java.util.*;

/**
 * Determines if a user entered String is a palindrome, which means the String
 * is the same forward and reverse. The determination is case-insensitive.
 * Spaces and punctuation must match for palindromes.
 * 
 * @author Dr. Sarah Heckman
 * @author Dr. Jessica Young Schmidt
 * @author Yan Chen
 */
public class Palindrome {

    /**
     * Starts program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        printPalindrome("abba");// palindrome
        printPalindrome("racecar");// palindrome
        printPalindrome("Madam");// palindrome
        printPalindrome("!!!Hannah!!!");// palindrome
        printPalindrome("! ! ! Hannah ! ! !");// palindrome
        printPalindrome("Dot saw I was tod");// palindrome
        printPalindrome("Step on no pets");// palindrome
        printPalindrome("Step on no pets!"); // NOT
        printPalindrome("dog"); // NOT
        printPalindrome("Java"); // NOT
        printPalindrome("abca"); // NOT
        System.out.println("\n*****Read from User*****");
        readConsole();
    }

    /**
     * Reads user's console input and prints the results
     */
    public static void readConsole() {
        Scanner in = new Scanner(System.in);
        System.out.print("Enter a word or phrase: ");
        String text = in.nextLine();
        printPalindrome(text);
    }

    /**
     * Prints whether text is a palindrome
     * @param text String to check whether it is a palindrome
     */
    public static void printPalindrome(String text) {
        System.out.print("isPalindrome: \t");
        if (isPalindrome(text)) {
            System.out.println("\"" + text + "\" is a palindrome");
        } else {
            System.out.println("\"" + text + "\" is NOT a palindrome");
        }
    }

    /**
     * Returns true if the text is a palindrome - the same word forward and
     * backwards
     * 
     * @param text String object to test if palindrome
     * @return whether text is a palindrome
     */
    public static boolean isPalindrome(String text) {
        String text1=text.toLowerCase(); //making the string case-insensitive
        int n = text.length();
        String text2=text1.substring(n-1);
        for (int i = 2; i <= n; i++){
            text2 = text2 + text1.substring(n-i,n-i+1);
        }
        //System.out.println(text2);
        
        if (text1.equals(text2)) {
           return true;
        } else {
           return false;
        }

    }

}
