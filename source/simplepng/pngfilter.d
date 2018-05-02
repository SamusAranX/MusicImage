module simplepng.filters;

//import std.range,
//       std.file,
//       std.array,
//       std.string,
//       std.stdio,
//       std.exception;

import std.stdio, std.file, std.bitmanip;

//import std.range.primitives : empty;

import std.bitmanip: read;

import std.zlib: compress, uncompress;

import std.math: floor;

import simplepng.headers;
import simplepng.exceptions;

class PNGFilter {

	//
	// Filter functions
	// used when encoding PNGs
	// https://www.w3.org/TR/2003/REC-PNG-20031110/#9Filters
	//

	static ubyte Filter(uint type, ubyte orig, ubyte a = 0, ubyte b = 0, ubyte c = 0) {
		switch (type) {
			case 0:
				return orig;
			case 1:
				return FilterSub(orig, a);
			case 2:
				return FilterUp(orig, b);
			case 3:
				return FilterAverage(orig, a, b);
			case 4:
				return FilterPaeth(orig, a, b, c);
			default:
				assert(0);
		}
	}

	// Type 1
	private static ubyte FilterSub(ubyte x, ubyte a) {
		return cast(ubyte)(x - a);
	}

	// Type 2
	private static ubyte FilterUp(ubyte x, ubyte b) {
		return cast(ubyte)(x - b);
	}

	// Type 3
	private static ubyte FilterAverage(ubyte x, ubyte a, ubyte b) {
		return cast(ubyte)(x - (a + b) / 2);
	}

	// Type 4
	private static ubyte FilterPaeth(ubyte x, ubyte a, ubyte b, ubyte c) {
		throw new PNGException("The Paeth filter method is currently unsupported");
		//return 0;
	}

	//
	// Reconstruction functions
	// used when decoding a PNG
	//

	static ubyte Recon(uint type, ubyte orig, ubyte a = 0, ubyte b = 0, ubyte c = 0) {
		switch (type) {
			case 0:
				return orig;
			case 1:
				return ReconSub(orig, a);
			case 2:
				return ReconUp(orig, b);
			case 3:
				return ReconAverage(orig, a, b);
			case 4:
				return ReconPaeth(orig, a, b, c);
			default:
				assert(0);
		}
	}

	// Type 1
	private static ubyte ReconSub(ubyte x, ubyte a) {
		auto uf = x + a;
		return cast(ubyte)uf;
	}

	// Type 2
	private static ubyte ReconUp(ubyte x, ubyte b) {
		auto uf = x + b;
		return cast(ubyte)uf;
	}

	// Type 3
	private static ubyte ReconAverage(ubyte x, ubyte a, ubyte b) {
		auto uf = x + (a + b) / 2;
		return cast(ubyte)uf;
	}

	// Type 4
	private static ubyte ReconPaeth(ubyte x, ubyte a, ubyte b, ubyte c) {
		throw new PNGException("The Paeth filter method is currently unsupported");
		//return 0;
	}

}