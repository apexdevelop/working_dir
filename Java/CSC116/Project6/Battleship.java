import java.util.*;

/**
 * The main engine for playing the battleship game.
 * @author Dan Longo 
 * @author Matt Stallmann
 * @author Suzanne Balik
 * @author David Sturgill
 */
public class Battleship {
	/** Number of rows on the game board. */
	public static final int ROWS = 8;

	/** Number of columns on the game board. */
	public static final int COLS = 8;

	/** Number of ships on the game board. */
	public static final int NUMBER_OF_SHIPS = 4;

	/** Length of each ship, in order. */
	public static final int [] SHIP_LENGTHS = { 1, 2, 3, 4 };

	/** Name for each ship, in the same order as length. */
	public static final String [] SHIP_NAMES = {"Submarine", "Destroyer", "Cruiser", "Battleship"};

	/** Current state of the human board. */
	private Board humanBoard;

	/** Current state of the computer board. */
	private Board computerBoard;

	/** Object that's making moves for the comptuer. */
	private BattleshipAI ai;

	/** True if all the human's ships have been placed (i.e., when we're playing the game.) */
	private boolean donePlacingShips = false;

	/** True if the next ship that's to be placed will be horizontal. */
	private boolean horizontal = true;

	/** Index of the ship that will be placed next. */
	private int shipIndex = 0;

	/** True if the whole game is over. */
	private boolean finished = false;

	/** Status message that's of interest to the user. */
	private String status = "";

	/**
	 * Constructor - sets up
	 *  - boards for human and computer
	 *  - panels for displaying these boards
	 *  - an AI program for the computer
	 *  - the GUI
	 * @param seed the random seed that is used for the computer's AI; if it's
	 * 0, the random sequence is unpredictable and not repeatable.
	 */
	public Battleship( long seed ) {
		humanBoard = new Board(ROWS, COLS, NUMBER_OF_SHIPS);
		computerBoard = new Board(ROWS, COLS, NUMBER_OF_SHIPS);
		ai = new BattleshipAI( computerBoard, seed );
		status = "Place " + SHIP_NAMES[0] + ", length = " + SHIP_LENGTHS[0]; 
	}

	/**
	 * Just like the one-parameter constructor, but don't supply a seed to the game AI.
	 */
	public Battleship() {
		humanBoard = new Board(ROWS, COLS, NUMBER_OF_SHIPS);
		computerBoard = new Board(ROWS, COLS, NUMBER_OF_SHIPS);
		ai = new BattleshipAI( computerBoard );
		status = "Place " + SHIP_NAMES[0] + ", length = " + SHIP_LENGTHS[0];
	}

	/**
	 * @return the computer player's board
	 */
	Board getComputerBoard() {
		return computerBoard;
	}

	/**
	 * @return the human player's board.
	 */
	Board getHumanBoard() {
		return humanBoard;
	}

	/**
	 * @return number of rows of the game board
	 */
	int getNumberOfRows() { return ROWS; }

	/**
	 * @return number of columns of the game board
	 */
	int getNumberOfColumns() { return COLS; }

	/**
	 * @return the number of ships used in the game
	 */
	public int getNumberOfShips() { return NUMBER_OF_SHIPS; } 

	/**
	 * @return the length of the i-th ship
	 */
	public int getShipLength( int i ) {
		return SHIP_LENGTHS[i];
	}

	/**
	 * @return the status of the game
	 */
	public String getStatus() {
		return status;
	}

	/**
	 * @return true if all the human player's ships have been placed.
	 */
	public boolean donePlacingShips() {
		// Just return the value of the field.
		return donePlacingShips;
	}

	/**
	 * If the player still needs to place a ship, return its length, otherwise
	 * undefined.
	 * @return length of the ship that will be placed next.
	 */
	public int placingLength() {
		return SHIP_LENGTHS[ shipIndex ];
	}

	/**
	 * Reacts to a mousePress in a grid square of the human player's grid 
	 * @param row the row of the grid in which the mouse was pressed
	 * @param column the column of the grid in which the mouse was pressed
	 */
	public void selectHumanGridSquare( int row, int column ) {

		if ( ! donePlacingShips ) {
			if ( ! humanBoard.addShip( SHIP_LENGTHS[shipIndex],
					horizontal, row, column ) ) {

				status = "No room: try again with " + SHIP_NAMES[shipIndex];
			}
			else {
				moveOnToNextShip();
			}

		}
	}

	/**
	 * Reacts to a mousePress in a grid square of the computer's grid 
	 * @param row the row of the grid in which the mouse was pressed
	 * @param column the column of the grid in which the mouse was pressed
	 */
	public void selectComputerGridSquare( int row, int column ) {

		if ( donePlacingShips && ! finished ) {
			if ( ! computerBoard.fireAtLocation( row, column ) ) {

				status = "Square already hit -- try again";
				return;
			}
			else {
				checkResults( computerBoard );
			}
			if ( ! finished ) { 
				computerTurn();
			}
			if ( ! finished ) {
				//FIX gui.putMessage("Your turn. Fire again.");
				status = "Your turn. Fire again.";
			}

		}
	}

	/**
	 * A ship has been successfully placed -- moves on to the next one
	 */
	public void moveOnToNextShip() {

		shipIndex++;
		if ( shipIndex < NUMBER_OF_SHIPS ) {

			status = "Place " + SHIP_NAMES[shipIndex] + ", length = " + SHIP_LENGTHS[shipIndex];

		}
		else {
			donePlacingShips = true;
			status = "Done placing ships. Firing begins"  + " (computer fired first).";
			computerTurn();
		}

	}

	/**
	 * Tell the game whether the currently placed ship will be horizontal.
	 * @param horizontal true if the next ship will be placed horizontally
	 */
	public void setHorizontal(boolean horizontal) {
		this.horizontal = horizontal;
	}

	/**
	 * Return true if the currently placed ship will be horizontal.  Undefined if all
	 * ships have been placed.
	 * @return true if the current ship will be placed horizontally.
	 */
	public boolean placingHorizontal() {
		return horizontal;
	}

	/**
	 * Checks the results of firing at a position and lets the GUI know if
	 * either party has won
	 */
	public void checkResults( Board board ) {
		if ( board.areAllShipsSunk() ) {
			if ( board == computerBoard ) {
				status = "Human Wins!";
			}
			else {
				status = "Computer Wins!";
			}
			finished = true;
		}
	}

	/**
	 * Computer takes a turn.
	 */
	public void computerTurn() {
		ai.fireAtHumanBoard( humanBoard );
		checkResults( humanBoard );
	} 
} 
