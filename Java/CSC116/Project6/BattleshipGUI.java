import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
/**
 * Provides GUI for Battleship game
 * @author Dan Longo
 * @author Matt Stallmann
 * @author Suzanne Balik
 * @author David Sturgill
 */
public class BattleshipGUI extends JFrame implements ActionListener {

	/** Font for all the UI controls. */
	private static final Font DEFAULT_FONT = new Font("Arial", 1, 20);

	/** Space around the game grids. */
	private static final int GRID_PADDING = 8;

	/** Reference to the game we're playing. */
	private Battleship game;

	/** GUI object showing the human board. */
	private Grid humanGrid;

	/** GUI object showing the computer board. */
	private Grid computerGrid;

	/** Button for switching to horizontal ship orientation. */
	private JButton hButton;

	/** Button for switching to vertical ship orientation. */
	private JButton vButton;

	/** Label showing the current status message. */
	private JLabel message;

	/** 
	 * Make a GUI for the battleship game.
	 * @param game Game object that keeps up with the current state of the game.
	 */
	public BattleshipGUI( Battleship game) {
		this.game = game;

		// Ships are visible on the human grid but not on the computer grid
		// (last argument)
		humanGrid = new Grid( game.getHumanBoard(), this, true );
		computerGrid = new Grid( game.getComputerBoard(), this, false );
		setTitle( "Battleship Game" );
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLayout( new BorderLayout() );

		Box gamePanel = new Box( BoxLayout.X_AXIS );
		add(gamePanel, BorderLayout.CENTER);

		// Add human and computer panels to the game; the human panel has a
		// title, grid, and buttons; the computer panel has only a title and a
		// grid
		Box humanBox = new Box( BoxLayout.Y_AXIS );
		Box computerBox = new Box( BoxLayout.Y_AXIS );
		gamePanel.add( Box.createRigidArea( new Dimension( GRID_PADDING, 0 ) ) );
		gamePanel.add( humanBox );
		gamePanel.add( Box.createRigidArea( new Dimension( GRID_PADDING, 0 ) ) );
		gamePanel.add( computerBox );
		gamePanel.add( Box.createRigidArea( new Dimension( GRID_PADDING, 0 ) ) );

		// Add three parts to the human panel
		JLabel humanLabel = new JLabel( "Human" );
		humanLabel.setAlignmentX( Component.CENTER_ALIGNMENT );
		humanLabel.setFont( DEFAULT_FONT );
		humanBox.add( humanLabel );
		humanBox.add( humanGrid );

		// Add two parts to the computer panel
		JLabel computerLabel = new JLabel( "Computer" );
		computerLabel.setAlignmentX( Component.CENTER_ALIGNMENT );
		computerLabel.setFont( DEFAULT_FONT );
		computerBox.add( computerLabel );
		computerBox.add( computerGrid );

		// South end of the window is a box, with a row for two buttons and
		// another row for the status message.
		Box southBox = new Box( BoxLayout.Y_AXIS );

		// Buttons for horizontal and vertical
		Box buttonBox = new Box( BoxLayout.X_AXIS );
		buttonBox.setAlignmentX( Component.CENTER_ALIGNMENT );
		hButton = new JButton("Horizontal");
		hButton.setFont( DEFAULT_FONT );
		hButton.addActionListener(this);
		vButton = new JButton("Vertical");
		vButton.setFont( DEFAULT_FONT );
		vButton.addActionListener(this);
		buttonBox.add( hButton );
		buttonBox.add( vButton );
		buttonBox.add(Box.createHorizontalGlue());
		southBox.add( buttonBox );

		message = new JLabel( "Game begins", SwingConstants.RIGHT );
		message.setAlignmentX( Component.CENTER_ALIGNMENT );
		message.setFont( DEFAULT_FONT );
		southBox.add( message );

		add( southBox, BorderLayout.SOUTH );

		updateStatus();

		pack();
		setVisible(true);
	}

	/**
	 * Update the status of the GUI based on any changes in the game object.
	 */
	private void updateStatus() {
		if ( game.donePlacingShips() ) {
			// Kill the ship highlight and disable the vertical/horizontal buttons.
			humanGrid.setHoverShape( null );
			hButton.setEnabled( false );
			vButton.setEnabled( false );
		} else {
			int len = game.placingLength();
			boolean horiz = game.placingHorizontal();
			humanGrid.setHoverShape( new Dimension( horiz ? len : 1,
					horiz ? 1 : len ) );
		}

		message.setText(game.getStatus());
		repaint();
	}

	/**
	 * Callback from the Grid objects, for when the button gets pressed.
	 * This is really an example of cyclic dependency, but, we'd need to use
	 * some more object-oriented features to do a good job fixing it.
	 * @param grid Grid object that was clicked on.
	 * @param row row of the grid that was clicked
	 * @param column column of the grid that was clicked
	 */
	public void gridPress( Grid grid, int row, int column ) {
		if ( grid == humanGrid ) {
			game.selectHumanGridSquare( row, column );
		}
		else {
			game.selectComputerGridSquare( row, column );
		}
		updateStatus();
		repaint();
	}

	/**
	 * Cranks up the game. The rest is driven by mouse events.
	 * @param args command-line arguments, possibly including a seed.
	 */
	public static void main( String args[] ) {

		if (args.length == 0) {
			new BattleshipGUI(new Battleship());
		}

		else if (args.length == 1) {
			try {
				int seed = Integer.parseInt(args[0]);
				new BattleshipGUI(new Battleship(seed));
			}
			catch (NumberFormatException e) {
				usageMessage();
				System.exit(1);
			}
		}
		else {
			usageMessage();
			System.exit(1);
		}

	}

	/**
	 * Callback used to respond to button presses.
	 * @param e event capturing information about the button press.
	 */
	public void actionPerformed(ActionEvent e) {
		if (e.getSource() == hButton) {
			game.setHorizontal(true);
		}
		if (e.getSource() == vButton) {
			game.setHorizontal(false);
		}
		updateStatus();
	}

	/**
	 * Prints a message about how the program should be used
	 */
	private static void usageMessage() {
		System.out.println( "Usage: java BattleShipGUI <seed>" );
	}
}


