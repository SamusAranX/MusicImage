module simplepng.png;

//import std.range,
//       std.file,
//       std.array,
//       std.string,
//       std.stdio,
//       std.exception;

import std.stdio, std.file, std.bitmanip;

//import std.range.primitives : empty;

import std.bitmanip: read, nativeToBigEndian;

import std.zlib: compress, uncompress;

import std.math: floor;

import simplepng.headers;
import simplepng.exceptions;

struct Color {
	ushort r;
	ushort g;
	ushort b;
	ushort a = 255;
}

class PNG {

	uint width;
	uint height;

	uint bitDepth;

	Color[][] pixels;
	Color[] pixels1D;

	this(uint w, uint h, ubyte[] values) {
		this.width = w;
		this.height = h;

		this.pixels = new Color[][](w, h);
		//this.pixels1D = new Color[](w*h);

		bool isRGB = values.length == this.width * this.height * 3;
		bool isRGBA = values.length == this.width * this.height * 4;

		bool isRGB16 = values.length == this.width * this.height * 6;
		bool isRGBA16 = values.length == this.width * this.height * 8;

		assert(isRGB || isRGBA || isRGB16 || isRGBA16);

		if (isRGB || isRGBA)
			this.bitDepth = 8;

		if (isRGB16 || isRGBA16)
			this.bitDepth = 16;

		auto valLen = values.length;

		if (isRGB || isRGB16) {
			uint stride = 3 * (this.bitDepth / 8);

			for (uint i = 0; i < valLen; i+=stride) {
				uint pixelIdx = i / stride;
				uint x = pixelIdx % w;
				uint y = pixelIdx / w;

				ushort r, g, b, a;

				if (this.bitDepth == 8) {
					r = cast(ushort)values.read!ubyte();
					g = cast(ushort)values.read!ubyte();
					b = cast(ushort)values.read!ubyte();
					a = 0xff;
				} else if (this.bitDepth == 16) {
					r = values.read!ushort();
					g = values.read!ushort();
					b = values.read!ushort();
					a = 0xffff;
				}

				this.pixels1D ~= *(new Color(r, g, b, a));
				this.pixels[x][y] = *(new Color(r, g, b, a));
			}
		} else if (isRGBA || isRGBA16) {
			uint stride = 4 * (this.bitDepth / 8);

			for (uint i = 0; i < valLen; i+=stride) {
				uint pixelIdx = i / stride;
				uint x = pixelIdx % w;
				uint y = pixelIdx / w;

				ushort r, g, b, a;

				if (this.bitDepth == 8) {
					r = cast(ushort)values.read!ubyte();
					g = cast(ushort)values.read!ubyte();
					b = cast(ushort)values.read!ubyte();
					a = cast(ushort)values.read!ubyte();
				} else if (this.bitDepth == 16) {
					r = values.read!ushort();
					g = values.read!ushort();
					b = values.read!ushort();
					a = values.read!ushort();
				}

				this.pixels1D ~= *(new Color(r, g, b, a));
				this.pixels[x][y] = *(new Color(r, g, b, a));
			}
		}
	}

	this(uint w, uint h, ushort[] values) {
		ubyte[] splitUshorts;
		foreach (ushort us; values) {
			splitUshorts ~= nativeToBigEndian(us);
		}

		this(w, h, splitUshorts);
	}

}