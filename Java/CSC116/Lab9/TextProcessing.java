/**
 * Program that provides methods for processing test
 * 
 * @author Jessica Young Schmidt
 * @author Yan Chen
 */
public class TextProcessing {

    /**
     * Starts the program.
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
        String redWhite = "We're the Red and White from State " + "And we know we are the best. "
                        + "A hand behind our back, " + "We can take on all the rest. "
                        + "Come over the hill, Caroline. " + "Devils and Deacs stand in line. "
                        + "The Red and White from N.C. State. " + "Go State!";
        String csc = "CSC";
        String blank = "";
        String name = "first middle last";

        // The values that should be returned from the method calls to
        // countWords, indexOf, and getWord are given in the comments
        System.out.println("countWords(redWhite): " + countWords(redWhite)); // 46
        System.out.println("countWords(csc): " + countWords(csc)); // 1
        System.out.println("countWords(blank): " + countWords(blank)); // 0
        System.out.println("countWords(name): " + countWords(name));// 3

        System.out.println("indexOf(csc, 'C', 1): " + indexOf(csc, 'C', 1));// 0
        System.out.println("indexOf(csc, 'C', 2): " + indexOf(csc, 'C', 2));// 2
        System.out.println("indexOf(redWhite, ' ', 2): " + indexOf(redWhite, ' ', 2));// 9

        System.out.println("getWord(redWhite, 5): " + getWord(redWhite, 5)); // "White"
        System.out.println("getWord(redWhite, 14): " + getWord(redWhite, 14)); // "best."
        System.out.println("getWord(redWhite, 45): " + getWord(redWhite, 45)); // "Go"
        System.out.println("getWord(redWhite, 46): " + getWord(redWhite, 46)); // "State!"
        System.out.println("getWord(csc, 1): " + getWord(csc, 1)); // "CSC"
        System.out.println("getWord(name, 1): " + getWord(name, 1)); // "first"
        System.out.println("getWord(name, 2): " + getWord(name, 2)); // "middle"
        System.out.println("getWord(name, 3): " + getWord(name, 3)); // "last"

    }

    /**
     * Counts the number of words in string. Assume that only whitespace is ' '.
     * ' ' represents breaks between words. There will only be one space between
     * words.
     * 
     * @param str String to count words
     * @return number of words in str
     */
    public static int countWords(String str) {
        int length = str.length();
        int countW;
        
        if (str==""){
            countW=0;
        } else {
        countW=1;
        for (int i = 0; i<length; i++) {
            if (str.charAt(i)==' ') {
                countW+=1;
            }
        }
        }
        return countW;
    }

    /**
     * Find index of the (num)th toFind in str
     * 
     * @param str String to examine
     * @param toFind char to find in str
     * @param num the repetition of toFind to find in str
     * @return index of the (num)th toFind in str, or -1 if doesn't exist
     * @throws IllegalArgumentException if num <= 0
     */
    public static int indexOf(String str, char toFind, int num) {
        int length = str.length();
        int countW=0;
        for (int i = 0; i<length; i++) {
            if (str.charAt(i)==toFind) {
                countW+=1;
            }
            if (countW==num) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Finds the (num)th word in str. Assume that only whitespace is ' '. ' '
     * represents breaks between words. There will only be one space between
     * words.
     * 
     * @param str String to examine
     * @param num the word to find
     * @return (num)th word in str
     * @throws IllegalArgumentException if num <= 0
     */
    public static String getWord(String str, int num) {
        int indS1;
        if (num == 1) {
            indS1 = -1;
        }  else {
           indS1 = indexOf(str,' ', num-1);
        }
        
        int indS2;
        if (num == countWords(str)) {
            indS2 = str.length();
        }  else {
           indS2 = indexOf(str,' ', num);
        }
        String word = "";
        word = str.substring(indS1+1,indS2);
        // HINT: consider case of only single word in str
        
        // HINT: use your indexOf() method above to find the
        //      index of the (num-1)th space and the (num)th space
     
        return word;
    }
}
