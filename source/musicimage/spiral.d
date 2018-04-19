module musicimage.spiral;

import std.stdio;
import std.getopt;
import std.math;
import std.algorithm;
import std.format;

struct Point {
	real x, y;

	PointInt toPointInt() {
		return PointInt(cast(int)round(this.x), cast(int)round(this.y));
	}
}

struct PointInt {
	int x, y;

	PointInt opBinary(string op)(PointInt other) {
		static if (op == "+")
			return PointInt(this.x + other.x, this.y + other.y);
		else static if (op == "-") 
			return PointInt(this.x - other.x, this.y - other.y);
		else static 
			assert(0, "Operator "~op~" not implemented");
	}

	void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const {
		switch(fmt.spec) {
			case 's':
				sink(format("PointInt { x: %04d, y: %04d }", this.x, this.y));
				break;
			default:
				throw new Exception("Unknown format specifier: %" ~ fmt.spec);
		}
	}

}

class Spiral {

	real startRadius, gap;
	Point centerPoint;
	real theta = 0.0;
	real r;

	this(real startRadius, Point center, real gap = 0.5) {
		this.startRadius = startRadius / 2;
		this.centerPoint = center;
		this.gap = gap;

		this.r = startRadius;
	}

	this(real startRadius, PointInt center, real gap = 0.5) {
		auto centerPoint = Point(cast(real)center.x, cast(real)center.y);
		this(startRadius, centerPoint, gap);
	}

	this(real startRadius, int center, real gap = 0.5) {
		auto centerPoint = Point(cast(real)center, cast(real)center);
		this(startRadius, centerPoint, gap);
	}

	this(real startRadius, real center, real gap = 0.5) {
		auto centerPoint = Point(center, center);
		this(startRadius, centerPoint, gap);
	}

	Point next() {
		this.theta += this.gap / this.r;
		this.r = this.startRadius + this.gap * this.theta;

		real x = this.r * cos(this.theta) + this.centerPoint.x;
		real y = this.r * sin(this.theta) + this.centerPoint.y;

		Point returnPoint = { x, y };

		return returnPoint;
	}

	PointInt[] oldCoords;
	PointInt nextRounded() {
		PointInt roundedCoords = this.next().toPointInt();

		// There's no point in checking all old coordinates
		// Limiting the number of points to check to 3200
		// This should only be a problem on obscenely slow computers
		int maxLastElements = min(this.oldCoords.length, 3200);

		while (this.oldCoords[$-maxLastElements..$].canFind(roundedCoords)) {
			roundedCoords = this.next().toPointInt();
		}

		this.oldCoords ~= roundedCoords;
		return roundedCoords;
	}

}
