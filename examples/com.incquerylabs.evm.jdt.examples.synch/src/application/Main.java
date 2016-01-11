package application;

import java.util.ArrayList;
import java.util.List;

import geometry.Shape;
import geometry.specific.Circle;
import geometry.specific.Rectangle;
import geometry.specific.Square;

public class Main {

	Rectangle rect;
	Circle circle;
	Square square;
	
	public void setupScene() {
		rect = new Rectangle(2, 4);
		rect.setColor("blue");
		
		circle = new Circle(3);
		circle.setColor("green");
		
		square = new Square(4);
		square.setColor("red");
	}
	
	public void drawScene() {
		List<Shape> shapes = new ArrayList<>();
		shapes.add(rect);
		shapes.add(circle);
		shapes.add(square);
		
		for (Shape shape : shapes) {
			shape.draw();
		}
	}
	
	public int totalAreaOfScene() {
		int total = 0;
		total += square.getArea();
		total += rect.getArea();
		total += circle.getArea();
		return total;
	}
	
	public static void main(String[] args) {
		Main m = new Main();
		m.setupScene();
		m.drawScene();
		System.out.println("Total area of scene: " + m.totalAreaOfScene());
	}
}
