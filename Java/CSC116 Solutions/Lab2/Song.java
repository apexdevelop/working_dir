/**
 * Outputs the lyrics of the song, “There Was an Old Lady Who Swallowed a Fly,”
 * by Simms Taback
 * 
 * @author Reges and Stepp
 * @author Jessica Young Schmidt (comments)
 */
public class Song {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        verse1();
        verse2();
        verse3();
        verse4();
        verse5();
        verse6();
    }

    /**
     * Prints verse 1
     */
    public static void verse1() {
        System.out.println("There was an old woman who swallowed a fly.");
        why1();
    }

    /**
     * Prints verse 2
     */
    public static void verse2() {
        System.out.println("There was an old woman who swallowed a spider,");
        System.out.println("That wriggled and iggled and jiggled inside her.");
        why2();
    }

    /**
     * Prints verse 3
     */
    public static void verse3() {
        System.out.println("There was an old woman who swallowed a bird,");
        System.out.println("How absurd to swallow a bird.");
        why3();
    }

    /**
     * Prints verse 4
     */
    public static void verse4() {
        System.out.println("There was an old woman who swallowed a cat,");
        System.out.println("Imagine that to swallow a cat.");
        why4();
    }

    /**
     * Prints verse 5
     */
    public static void verse5() {
        System.out.println("There was an old woman who swallowed a dog,");
        System.out.println("What a hog to swallow a dog.");
        why5();
    }

    /**
     * Prints verse 6
     */
    public static void verse6() {
        System.out.println("There was an old woman who swallowed a horse,");
        System.out.println("She died of course.");
    }

    /**
     * Prints why 1
     */
    public static void why1() {
        System.out.println("I don't know why she swallowed that fly,");
        System.out.println("Perhaps she'll die.");
        System.out.println();
    }

    /**
     * Prints why 2
     */
    public static void why2() {
        System.out.println("She swallowed the spider to catch the fly,");
        why1();
    }

    /**
     * Prints why 3
     */
    public static void why3() {
        System.out.println("She swallowed the bird to catch the spider,");
        why2();
    }

    /**
     * Prints why 4
     */
    public static void why4() {
        System.out.println("She swallowed the cat to catch the bird,");
        why3();
    }

    /**
     * Prints why 5
     */
    public static void why5() {
        System.out.println("She swallowed the dog to catch the cat,");
        why4();
    }
}
