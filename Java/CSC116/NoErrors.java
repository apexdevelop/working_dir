/**
 * This file corrects all the errors in LotsOfErrors.java
 * @author Yan Chen
 */

public class NoErrors {
    public static void main(String[] args) {
        System.out.println("Hello, world!");
        message(); //static statement
    }

    public static void message() {
        System.out.println("This program surely cannot ");
        System.out.println("have any \"errors\" in it");
    }
}