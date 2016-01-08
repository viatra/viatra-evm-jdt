package geometry.specific;

import color.ColoredElement;
import geometry.Shape;

public class Rectangle extends ColoredElement implements Shape {

	int height;
	int width;
	
	public Rectangle(int height, int width) {
		this.height = height;
		this.width = width;
	}
	
	@Override
	public int getArea() {
		return height*width;
	}

	@Override
	public void draw() {
		System.out.println(String.format("Drawing rectangle with %s height, %s width", height, width));
	}

}
