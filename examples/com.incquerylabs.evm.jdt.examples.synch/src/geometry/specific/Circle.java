package geometry.specific;

import color.ColoredElement;
import geometry.Shape;

public class Circle extends ColoredElement implements Shape {

	int radius;
	
	public Circle(int radius) {
		this.radius = radius;
	}
	
	@Override
	public int getArea() {
		return (int)(Math.PI * radius * radius);
	}

	@Override
	public void draw() {
		System.out.println(String.format("Drawing circle with %s radius", radius));
	}

}
