import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

/**
 * The tricky part of this class is to realize that x-coordinates on the grid
 * translate to columns in the game and y-coordinates to rows.
 * @author Matt Stallmann
 * @author Suzanne Balik
 * @author David Sturgill
 */
public class Grid extends JPanel implements MouseListener, MouseMotionListener {

	/** Size of each grid cell, in pixels. */
	private static final int CELL_SIZE = 50;

	/** Smallest size we'd like for a cell */
	private static final int MIN_CELL_SIZE = 10;

	/** to allow room for text labels when they are added */
	private static final int TEXT_SIZE = 10;

	/** Size for a hit/miss circle drawn in a grid cell. */
	private static final int CIRCLE_SIZE = 30;

	/** Color of the sea. */
	private static final Color SEA = new Color(108, 182, 255);

	/** State of the game we're playing. */
	private Board board;

	/** Gui object that created this grid.  It's for the mouse-down callback. */
	private BattleshipGUI gui;

	/** True if we should show all the ships (for the human player board). */
	private boolean visible;

	/** Size of the object being placed, or null if there's no object. */
	private Dimension hoverShape;

	/** Last place where the user had the mouse ( y <- row, x <- column ) */
	private Point hoverPosition = new Point();

	/**
	 * Constructor: draws a game board and awaits mouse events
	 * @param board the board that will be drawn each time
	 * @param gui the GUI to which mouse events will be dispatched
	 * @param visible true if all the ships should be shown, as is the case
	 * with the human's board
	 */
	public Grid( Board board, BattleshipGUI gui, boolean visible )
	{
		this.board = board;
		this.gui = gui;
		this.visible = visible;
		addMouseListener( this );
		addMouseMotionListener( this );
		repaint();
	}

	/**
	 * Tell the grid the shape of the object we're placing, or
	 * null if we don't have a hover shape.
	 * @param shape width and height (in grid units) for the thing beign placed.
	 */
	public void setHoverShape( Dimension shape ) {
		hoverShape = shape;
	}

	/**
	 * Callback for repainting the contents of the window.  Called
	 * automatically by the GUI framework.
	 * @param g graphics object to use for drawing.
	 */
	public void paint( Graphics g ) {
		// Apply a transformation to scale up/down the drawing
		// based on the component size.
		Graphics2D g2d = (Graphics2D)g;
		int rows = board.getNumberOfRows();
		int cols = board.getNumberOfColumns();
		Dimension dim = getSize( null );
		g2d.scale(  (double) dim.width / cols / CELL_SIZE,
		            (double) dim.height / rows / CELL_SIZE );

		g.setColor( SEA );
		g.fillRect( 0, 0, cols * CELL_SIZE, rows * CELL_SIZE );
		drawGrid(g);
		drawHoverShape(g);
		drawHits(g);
		drawShips(g);
		drawShipHits(g);
	}

	/**
	 * Draw the grid behind all the ships.
	 * @param g graphics object to use for drawing.
	 */
	public void drawGrid(Graphics g) {
		g.setColor(Color.black);
		// Paint horizontal lines
		int rows = board.getNumberOfRows();
		int cols = board.getNumberOfColumns();
		for(int i = 1; i < rows; i++)
		{
			g.drawLine(0, i * CELL_SIZE,
					cols * CELL_SIZE, i * CELL_SIZE);
		}
		// Paint vertical lines
		for(int i = 1; i < cols; i++)
		{
			g.drawLine( i * CELL_SIZE, 0,
					i * CELL_SIZE, rows * CELL_SIZE );
		}
	}

	/**
	 * Draw a circle representing a hit or a miss.
	 * @param g graphics object to use for drawing.
	 * @param row row location for the circle
	 * @param col column location for the circle
	 */
	private void drawCircle(Graphics g, int row, int col) {
		int offset = (CELL_SIZE - CIRCLE_SIZE) / 2;
		// Note: x coordinate -> column; y -> row
		g.fillOval( col * CELL_SIZE + offset,
				row * CELL_SIZE + offset,
				CIRCLE_SIZE, CIRCLE_SIZE );
	}

	/**
	 * Draw all the places where a cell was hit without a ship in it.
	 * @param g graphics object to use for drawing.
	 */
	public void drawHits(Graphics g) {
		g.setColor(Color.white);
		for ( int row = 0; row < board.getNumberOfRows(); row++ ) {
			for ( int col = 0; col < board.getNumberOfColumns(); col++ ) {
				if ( board.hasBeenHit( row, col ) ) {
					drawCircle(g, row, col);
				}
			}
		}
	}

	/**
	 * Draw an outline to indicate where the user is placing a ship.
	 * @param g graphics object to use for drawing.
	 */
	public void drawHoverShape(Graphics g) {
		if ( hoverShape != null ) {
			g.setColor(Color.yellow );

			int upperLeftX = CELL_SIZE * hoverPosition.x;
			int upperLeftY = CELL_SIZE * hoverPosition.y;
			int width = hoverShape.width * CELL_SIZE;
			int height = hoverShape.height * CELL_SIZE;
			g.drawOval( upperLeftX, upperLeftY, width, height );
		}
	}

	/**
	 * Draw all the ships to the grid.
	 * @param g graphics object to use for drawing.
	 */
	public void drawShips(Graphics g) {
		g.setColor(Color.lightGray);
		Ship [] ships = board.getShips();
		for ( int i = 0; i < board.getNumberOfShips(); i++ ) {
			if ( ships[i] == null ) break;
			if ( ! visible && ! ships[i].isSunk() ) continue;
			// Note: x coordinate -> column; y -> row
			int upperLeftX = CELL_SIZE * ships[i].getStartCol();
			int upperLeftY = CELL_SIZE * ships[i].getStartRow();
			int width = CELL_SIZE;
			if ( ships[i].isHorizontal() )
				width = CELL_SIZE * ships[i].getLength();
			int height = CELL_SIZE;
			if ( ! ships[i].isHorizontal() )
				height = CELL_SIZE * ships[i].getLength();
			g.fillOval( upperLeftX, upperLeftY, width, height );
		}
	}

	/**
	 * Draw all the places where a ship has been hit.
	 * @param g graphics object to use for drawing.
	 */
	public void drawShipHits(Graphics g) {
		g.setColor(Color.red);
		Ship [] ships = board.getShips();
		for ( int i = 0; i < board.getNumberOfShips(); i++ ) {
			if ( ships[i] == null ) break;
			int topRow = ships[i].getStartRow();
			int leftCol = ships[i].getStartCol();
			int length = ships[i].getLength();
			if ( ships[i].isHorizontal() ) {
				for ( int col = leftCol; col < leftCol + length; col++ ) {
					if ( board.hasBeenHit(topRow, col) ) drawCircle( g, topRow, col );
				} 
			}
			else {
				for ( int row = topRow; row < topRow + length; row++ ) {
					if ( board.hasBeenHit(row, leftCol) ) drawCircle( g, row, leftCol );
				} 
			}
		}
	}

	///////////////
	// MouseListener
	///////////////

	/**
	 * Callback for when a mouse button is clicked (down/up).  Not used.
	 */
	public void mouseClicked(MouseEvent e) {
	}

	/**
	 * Callback for when the mouse pointer enters the window.  Not used.
	 */
	public void mouseEntered(MouseEvent e) {
	}

	/**
	 * Callback for when the mouse pointer leaves the window.  Not used.
	 */
	public void mouseExited(MouseEvent e) {
	}

	/**
	 * Callback for when a mouse button is released.  Not used.
	 */
	public void mouseReleased(MouseEvent e){
	}

	/**
	 * Callback for when a mouse button is pressed on the grid.
	 * We convert it to row and column, and notify the GUI object.
	 */
	public void mousePressed(MouseEvent e) {
		// Note: x coordinate -> column; y -> row
		Dimension dim = getSize( null );
		int row = e.getY() * board.getNumberOfColumns() / dim.height;
		int column = e.getX() * board.getNumberOfRows() / dim.width;
		gui.gridPress( this, row, column );
	}

	///////////////
	// MouseMotionListener
	///////////////

	/**
	 * Callback for when the mouse is moved with a button down, not used.
	 */
	public void mouseDragged( MouseEvent e ) {
	}

	/**
	 * Callback for when the mouse is moved in the window.  We remember the mouse location
	 * to draw the highlight of the ship being placed.
	 */
	public void mouseMoved( MouseEvent e ) {
		if ( hoverShape != null ) {
			Dimension dim = getSize( null );
			hoverPosition.y = e.getY() * board.getNumberOfColumns() / dim.height;
			hoverPosition.x = e.getX() * board.getNumberOfRows() / dim.width;
			repaint();
		}
	}

	/**
	 * For layout, report the size this component wants to be. 
	 */
	public Dimension getPreferredSize() {
		return new Dimension( board.getNumberOfColumns() * CELL_SIZE,
					board.getNumberOfRows() * CELL_SIZE );
	}

	/**
	 * For layout, report the minimum size this component will tolerate.
	 */
	public Dimension getMinimumSize() {
		return new Dimension( board.getNumberOfColumns() * MIN_CELL_SIZE,
					board.getNumberOfRows() * MIN_CELL_SIZE );
	}

}

