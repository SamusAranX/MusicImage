module simplepng.headers;

import std.bitmanip: bigEndianToNative, nativeToBigEndian;
import std.conv: to;

class PngHeaders {

	//template MakeAutoProperties(string name, string type) {
	//	const char[] props = "@property " ~ type ~ " " ~ name ~ "() { return bigEndianToNative!" ~ type ~ "(" ~ name ~ "!_); }\n"~
	//	"@property void " ~ name ~ "(" ~ type ~ " v) { " ~ name ~ "_ = nativeToBigEndian!" ~ type ~ "(v); }";
	//}

	struct MakeStructStruct {
		string typeName;
		uint   typeSize;
		string fieldName;
		string castFrom = "";
	}

	//@property uint Width() { return bigEndianToNative!uint(Width_); }
	//@property void Width(uint v) { Width_ = nativeToBigEndian!uint(v); }
	//@property IHDR_BitDepth BitDepth() { return cast(IHDR_BitDepth)bigEndianToNative!uint(BitDepth_); }
	//@property void BitDepth(IHDR_BitDepth v) { BitDepth_ = v; }
	//@property void BitDepth(ubyte v) { BitDepth_ = cast(IHDR_BitDepth)nativeToBigEndian!ubyte(v); }
	static string MakeStruct(string name, MakeStructStruct[] fields) {
		string str = "struct " ~ name ~ "{\n\talign(1):\n";

		foreach (MakeStructStruct field; fields) {
			string tn = field.typeName;
			string ts = to!string(field.typeSize);
			string fn = field.fieldName; // the field name, e.g. "Width"

			str ~= "\tubyte[" ~ ts ~ "] " ~ fn ~ "_;\n";

			if (field.castFrom.length == 0) {
				// t is uint or ubyte etc.
				str ~= "\t@property " ~ tn ~ " " ~ fn ~ "() {\n" ~
					"\t\treturn bigEndianToNative!" ~ tn ~ "(" ~ fn ~ "_);\n" ~
				"\t}\n";
				str ~= "\t@property void " ~ fn ~ "(" ~ tn ~ " v) {\n" ~ 
					"\t\t" ~ fn ~ "_ = nativeToBigEndian!" ~ tn ~ "(v);\n" ~
				"\t}";
			} else {
				string c = field.castFrom;

				// t is IHDR_BitDepth etc.
				// c is uint etc.

				str ~= "\t@property " ~ tn ~ " " ~ fn ~ "() {\n" ~ 
					"\t\treturn *cast(" ~ tn ~ "*)[bigEndianToNative!" ~ c ~ "(" ~ fn ~ "_)];\n" ~
				"\t}\n";
				str ~= "\t@property void " ~ fn ~ "(" ~ tn ~ " v) {\n" ~ 
					"\t\t" ~ fn ~ "_ = v;\n" ~ 
				"\t}\n";
				//str ~= "\t@property void " ~ fn ~ "(" ~ c ~ " v) {\n" ~ 
				//	"\t\t" ~ fn ~ "_ = *cast(" ~ tn ~ "*)[nativeToBigEndian!" ~ c ~ "(v)];\n" ~
				//"\t}";
			}
			str ~= "\n\n";
		}

		str ~= "}";

		return str;
	}

	immutable static ulong PNG_SIGNATURE = 0x89504E470D0A1A0A; // first 8 bytes
	immutable static uint  PNG_IHDR      = 0x49484452; // IHDR

	static enum PNG_CHUNKTYPE: uint {
		// critical chunks
		IHDR = 0x49484452, // IHDR
		PLTE = 0x504C5445, // PLTE
		IDAT = 0x49444154, // IDAT
		IEND = 0x49454E44, // IEND

		// non-critical chunks start here
		CHRM = 0x6348524D, // cHRM
		GAMA = 0x67414D41, // gAMA
		ICCP = 0x69434350, // iCCP
		SBIT = 0x73424954, // sBIT
		SRGB = 0x73524742, // sRGB
		BKGD = 0x624B4744, // bKGD
		HIST = 0x68495354, // hIST
		TRNS = 0x74524E53, // tRNS
		PHYS = 0x70485973, // pHYs
		SPLT = 0x73504C54, // sPLT
		TIME = 0x74494D45, // tIME
		ITXT = 0x69545874, // iTXt
		TEXT = 0x74455874, // tEXt
		ZTXT = 0x7A545874, // zTXt
	}

	//
	// IHDR Chunk
	//

	static enum IHDR_BitDepth: ubyte {
		BitDepth1  = 1,
		BitDepth2  = 2,
		BitDepth4  = 4,
		BitDepth8  = 8,
		BitDepth16 = 16
	}

	static enum IHDR_ColorType: ubyte {
		Greyscale      = 0,
		TrueColor      = 2,
		Indexed        = 3,
		GreyscaleAlpha = 4,
		TrueColorAlpha = 6
	}

	static enum IHDR_CompressionMethod: ubyte {
		Deflate = 0
	}

	static enum IHDR_FilterMethod: ubyte {
		Adaptive = 0
	}

	static enum IHDR_InterlaceMethod: ubyte {
		NoInterlace    = 0,
		Adam7Interlace = 1
	}

	mixin(MakeStruct("IHDR",
		[
			MakeStructStruct("uint", 4,                   "Width"),
			MakeStructStruct("uint", 4,                   "Height"),
			MakeStructStruct("IHDR_BitDepth", 1,          "BitDepth",          "ubyte"),
			MakeStructStruct("IHDR_ColorType", 1,         "ColorType",         "ubyte"),
			MakeStructStruct("IHDR_CompressionMethod", 1, "CompressionMethod", "ubyte"),
			MakeStructStruct("IHDR_FilterMethod", 1,      "FilterMethod",      "ubyte"),
			MakeStructStruct("IHDR_InterlaceMethod", 1,   "InterlaceMethod",   "ubyte"),
		]
	));

	//struct IHDR {
	//	align(1): // don't pad this struct so .sizeof works properly
	//	uint Width;
	//	uint Height;
	//	IHDR_BitDepth BitDepth;
	//	IHDR_ColorType ColorType;
	//	IHDR_CompressionMethod CompressionMethod;
	//	IHDR_FilterMethod FilterMethod;
	//	IHDR_InterlaceMethod InterlaceMethod;

	//	//@property uint Width() { return bigEndianToNative!uint(Width_); }
	//	//@property void Width(uint w) { Width_ = nativeToBigEndian!uint(w); }
	//	//@property uint Height() { return bigEndianToNative(Height_); }
	//}

}