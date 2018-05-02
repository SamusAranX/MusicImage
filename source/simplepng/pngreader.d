module simplepng.pngreader;

//import std.range,
//       std.file,
//       std.array,
//       std.string,
//       std.stdio,
//       std.exception;

import std.stdio, std.file, std.bitmanip;
import std.container;

//import std.range.primitives : empty;

import std.bitmanip: read;

import std.zlib: compress, uncompress;

import simplepng.headers;
import simplepng.exceptions;
import simplepng.filters;
import simplepng.png;

class PNGReader {

	static PNG readPNG(string fname) {
		File file = File(fname, "rb");

		try {
		    auto ps = file.rawRead(new ubyte[8]);
			assert(ps.read!ulong() == PNG_SIGNATURE);

			auto hcl = file.rawRead(new ubyte[4]);
			uint headerChunkLength = hcl.read!uint();

			// make sure the header's length is actually what was specified
			assert(PNGHeaders.IHDR.sizeof == headerChunkLength);
		} catch(Throwable) {
			// purposefully catching everything
			throw new PNGException("This PNG is hella invalid");
		}

		PNGHeaders.IHDR ihdr;
		try {
		    // make sure this is actually an IHDR chunk
			ubyte[] chunkHeader = file.rawRead(new ubyte[4]);
			assert(chunkHeader.read!uint() == PNG_CHUNKTYPE.IHDR);
			file.rawRead((&ihdr)[0..1]);
			file.rawRead(new ubyte[4]); // consume and ignore CRC
		} catch(Throwable) {
			// purposefully catching everything
			throw new PNGException("Invalid IHDR chunk");
		}
		
		writeln(ihdr);
		writefln("%d×%d", ihdr.Width, ihdr.Height);
		writeln(ihdr.BitDepth);
		writeln(ihdr.ColorType);
		writeln(ihdr.CompressionMethod);
		writeln(ihdr.FilterMethod);
		writeln(ihdr.InterlaceMethod);

		if (!(ihdr.ColorType == IHDR_ColorType.TrueColor || ihdr.ColorType == IHDR_ColorType.TrueColorAlpha))
			throw new PNGException("PNGs that are not truecolor are not supported");

		if (ihdr.BitDepth < 8)
			throw new PNGException("PNGs with fewer than 8 bits per color are not supported");

		if (ihdr.FilterMethod != 0)
			throw new PNGException("Invalid filter method specified");

		if (ihdr.CompressionMethod != 0)
			throw new PNGException("Invalid compression method specified");

		PNG png;

		while (file.tell < file.size) {
			uint chunkLength = bigEndianToNative!uint(file.rawRead(new ubyte[4])[0..4]);
			uint chunkHeader = bigEndianToNative!uint(file.rawRead(new ubyte[4])[0..4]);

			if (chunkLength > 0) {
				auto chunkData = file.rawRead(new ubyte[chunkLength]);

				switch (chunkHeader) {
					case PNG_CHUNKTYPE.IDAT:
						writeln("IDAT chunk found");

						png = decodeIDAT(chunkData, ihdr);

						break;
					case PNG_CHUNKTYPE.IEND:
						writeln("File end reached");
						break;
					default:
						break;
						//writeln("unknown chunk");
				}
			}

			file.rawRead(new ubyte[4]); // consume and ignore CRC
		}

		file.close();

		return png;
	}

	private static PNG decodeIDAT(ubyte[] idat, PNGHeaders.IHDR ihdr) {
		ubyte[] uncompressed = cast(ubyte[])uncompress(idat);

		uint pixelWidth;
		if (ihdr.ColorType == IHDR_ColorType.TrueColor)
			pixelWidth = 3;
		else if(ihdr.ColorType == IHDR_ColorType.TrueColorAlpha)
			pixelWidth = 4;

		if (ihdr.BitDepth > 8)
			pixelWidth *= 2;

		ubyte[] unfilteredArr;
		writeln(pixelWidth);

		auto rowWidth = ihdr.Width * pixelWidth;

		for (uint y = 0; y < ihdr.Height; y++) {
			ubyte filterType = uncompressed.read!ubyte();

			for (uint x = 0; x < rowWidth; x++) {
				ubyte filteredByte = uncompressed.read!ubyte();

				ubyte byteLeft = 0, byteAbove = 0, byteLeftAbove = 0;

				bool firstPixelInScanline = x < pixelWidth;
				bool firstScanline        = y == 0;

				if (!firstPixelInScanline)
					byteLeft        = unfilteredArr[y*rowWidth+x-pixelWidth];

				if (!firstScanline)
					byteAbove       = unfilteredArr[(y-1)*rowWidth+x];

				if (!firstScanline && !firstPixelInScanline)
					byteLeftAbove   = unfilteredArr[(y-1)*rowWidth+x-pixelWidth];

				ubyte unfilteredByte = 0;

				unfilteredByte = PNGFilter.Recon(filterType, filteredByte, byteLeft, byteAbove, byteLeftAbove);

				unfilteredArr ~= unfilteredByte;
			}
		}

		return new PNG(ihdr.Width, ihdr.Height, unfilteredArr);
	}

}