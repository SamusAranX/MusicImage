module simplepng.pngreader;

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

import simplepng.headers;
import simplepng.exceptions;

class PngReader {

	this(string fname) {
		File file = File(fname, "r");

		try {
		    auto ps = file.rawRead(new ubyte[8]);
			assert(ps.read!ulong() == PngHeaders.PNG_SIGNATURE);

			auto hcl = file.rawRead(new ubyte[4]);
			uint headerChunkLength = hcl.read!uint();

			// make sure the header's length is actually what was specified
			assert(PngHeaders.IHDR.sizeof == headerChunkLength);
		} catch(Throwable) {
			// purposefully catching everything
			throw new PngException("This PNG is hella invalid");
		}

		PngHeaders.IHDR ihdr;
		try {
		    ihdr = this.getIHDRChunk(file);
		} catch(Throwable) {
			// purposefully catching everything
			throw new PngException("Invalid IHDR chunk");
		}
		
		writeln(ihdr);
		writeln(ihdr.Width);
		writeln(ihdr.Height);
		writeln(ihdr.BitDepth);
		writeln(ihdr.ColorType);
		writeln(ihdr.CompressionMethod);
		writeln(ihdr.FilterMethod);
		writeln(ihdr.InterlaceMethod);

		if (ihdr.BitDepth < 8)
			throw new PngException("PNGs with fewer than 8 bits per color are not supported");

		if (!(ihdr.ColorType == PngHeaders.IHDR_ColorType.TrueColor || ihdr.ColorType == PngHeaders.IHDR_ColorType.TrueColorAlpha))
			throw new PngException("PNGs that are not truecolor are not supported");


		while (file.tell < file.size) {
			//writefln("%d/%d", file.tell, file.size);

			uint chunkLength = bigEndianToNative!uint(file.rawRead(new ubyte[4])[0..4]);
			uint chunkHeader = bigEndianToNative!uint(file.rawRead(new ubyte[4])[0..4]);

			//writefln("Chunk length: %d", chunkLength);

			switch (chunkHeader) {
				case PngHeaders.PNG_CHUNKTYPE.ICCP:
					writeln("iCCP chunk found");
					break;
				case PngHeaders.PNG_CHUNKTYPE.PHYS:
					writeln("pHYs chunk found");
					break;
				case PngHeaders.PNG_CHUNKTYPE.ITXT:
					writeln("iTXt chunk found");
					break;
				case PngHeaders.PNG_CHUNKTYPE.IDAT:
					writeln("IDAT chunk found");
					break;
				case PngHeaders.PNG_CHUNKTYPE.IEND:
					writeln("File end reached");
					break;
				default:
					writeln("unknown chunk");
			}

			if (chunkLength > 0) {
				auto chunkData = file.rawRead(new ubyte[chunkLength]);
				if (chunkHeader == PngHeaders.PNG_CHUNKTYPE.IDAT) {
					auto uncompressed = uncompress(chunkData);

					int bytesPerPixel = 0;

					writeln(uncompressed);
				}
			}

			file.rawRead(new ubyte[4]); // consume and ignore CRC

			//break;
		}

		//assert(read!(uint, Endian.bigEndian)(ihdrBytes) == PngHeaders.PNG_CHUNKTYPE.IHDR);

		//PngHeaders.IHDR ihdr = (*cast(PngHeaders.IHDR*)ihdr_bytes);

		//writeln(ihdr);


		file.close();
	}

	PngHeaders.IHDR getIHDRChunk(ref File f) {
		PngHeaders.IHDR ihdr;

		// make sure this is actually an IHDR chunk
		ubyte[] chunkHeader = f.rawRead(new ubyte[4]);
		assert(chunkHeader.read!uint() == PngHeaders.PNG_CHUNKTYPE.IHDR);

		f.rawRead((&ihdr)[0..1]);

		f.rawRead(new ubyte[4]); // consume and ignore CRC

		return ihdr;
	} 

}
