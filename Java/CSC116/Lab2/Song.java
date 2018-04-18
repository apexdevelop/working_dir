/**
 * Print a song with static Methods - structured, without redundancy
 * 
 * @author Yan Chen
 *
 */
public class Song {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        first();
        second();
        third();
        fourth();
        fifth();
        sixth();
    }
    
    /**
     * Print "I don't know why she swallowed that fly,".
     */
    public static void dont_know() {
        System.out.println("I don't know why she swallowed that fly,");
    }
    
    /**
     * Print "Perhaps she'll die".
     */
    public static void die() {
        System.out.println("Perhaps she'll die.");
    }
    
    /**
     * Print first verse.
     */
    public static void first() {
        System.out.println("There was an old woman who swallowed a fly.");
        dont_know();
        die();
        System.out.println();
    }
    
    /**
     * Print "She swallowed the spider to catch the fly,".
     */
    public static void swa_spider() {
        System.out.println("She swallowed the spider to catch the fly,");
    }
    
    /**
     * Print second verse.
     */
    public static void second() {
        System.out.println("There was an old woman who swallowed a spider.");
        System.out.println("That wriggled and iggled and jiggled inside her.");
        swa_spider();
        dont_know();
        die();
        System.out.println();
    }
    
    /**
     * Print "She swallowed the bird to catch the spider,".
     */
    public static void swa_bird() {
        System.out.println("She swallowed the bird to catch the spider,");
    }
    
    /**
     * Print third verse.
     */
    public static void third() {
        System.out.println("There was an old woman who swallowed a bird.");
        System.out.println("How absurd to swallow a bird.");
        swa_bird();
        swa_spider();
        dont_know();
        die();
        System.out.println();
    }

    /**
     * Print "She swallowed the cat to catch the bird,".
     */
    public static void swa_cat() {
        System.out.println("She swallowed the cat to catch the bird,");
    }

    /**
     * Print fourth verse.
     */
    public static void fourth() {
        System.out.println("There was an old woman who swallowed a cat.");
        System.out.println("Imagine that to swallow a cat.");
        swa_cat();
        swa_bird();
        swa_spider();
        dont_know();
        die();
        System.out.println();
    }

    /**
     * Print "She swallowed the dog to catch the cat,".
     */
    public static void swa_dog() {
        System.out.println("She swallowed the dog to catch the cat,");
    }

    /**
     * Print fifth verse.
     */
    public static void fifth() {
        System.out.println("There was an old woman who swallowed a dog.");
        System.out.println("What a hog to swallow a dog.");
        swa_dog();
        swa_cat();
        swa_bird();
        swa_spider();
        dont_know();
        die();
        System.out.println();
    }
    
    /**
     * Print sixth verse.
     */
    public static void sixth() {
        System.out.println("There was an old woman who swallowed a horse.");
        System.out.println("She died of course.");
    }

}