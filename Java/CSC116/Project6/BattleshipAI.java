import java.util.*;

/**
 * A very stupid computer strategy, everything random. In order to make this
 * smarter, you would need a Board method that lets the computer know
 * whether the most recent firing hit a ship and/or some information about
 * the progress of the game.
 */

public class BattleshipAI {

	private Board computerBoard;
	private Random rand;

	/**
	 * Constructor
	 * initializes instance variables, sets up the random number sequence and
	 * places the ships
	 * @param game the current game (not implemented); needed to allow computer
	 * to fire in an intelligent fashion; this would also require the game to
	 * implement a method that allows the computer to determine whether a ship
	 * has been hit
	 * @param computerBoard the computer's game board; used for placing the ships
	 * @param seed the random number seed; not used if seed = 0
	 */
	public BattleshipAI(Board computerBoard, long seed) {
		this.computerBoard = computerBoard;
		rand = new Random( seed );
		setUpShips();
	}

	/**
	 * Constructor
	 * initializes instance variables, sets up the random number sequence and
	 * places the ships
	 * @param game the current game (not implemented); needed to allow computer
	 * to fire in an intelligent fashion; this would also require the game to
	 * implement a method that allows the computer to determine whether a ship
	 * has been hit
	 * @param computerBoard the computer's game board; used for placing the ships
	 * @param seed the random number seed; not used if seed = 0
	 */
	public BattleshipAI(Board computerBoard) {
		this.computerBoard = computerBoard;
		rand = new Random();
		setUpShips();
	}

	/** sets up ships in a random fashion */
	private void setUpShips() {
		for (int i = 0; i < Battleship.NUMBER_OF_SHIPS; i++) {
			boolean successful = false;
			while(!successful) {
				int orientation = rand.nextInt(2);
				boolean horizontal = true;
				if (orientation == 1) {
					horizontal = false;
				}
				int row = rand.nextInt(computerBoard.getNumberOfRows());
				int col = rand.nextInt(computerBoard.getNumberOfColumns());
				if (computerBoard.addShip(Battleship.SHIP_LENGTHS[i], horizontal, 
						row, col)) {
					successful = true;
				}
			}
		}
	}

	/** Chooses a random position for firing at the board of the human player */
	public void fireAtHumanBoard(Board humanBoard) {
		boolean successful = false;
		while (!successful) {
			int row = rand.nextInt(computerBoard.getNumberOfRows());
			int col = rand.nextInt(computerBoard.getNumberOfColumns());
			if (!humanBoard.hasBeenHit(row, col)) {
				humanBoard.fireAtLocation(row, col);
				successful = true;
			}
		}
	}
}






