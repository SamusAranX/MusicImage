module simplepng.helpers;

class PngHelpers {

	static uint[256] crc_table;
	static bool      crc_table_computed;

	static void make_crc_table() {
		uint c, n, k;

		for (n = 0; n < 256; n++) {
			c = n;
			for (k = 0; k < 8; k++) {
				if (c & 1)
					c = 0xEDB88320 ^ (c >> 1);
				else
					c = c >> 1;
			}
			this.crc_table[n] = c;
		}

		this.crc_table_computed = true;
	}

	static uint update_crc(uint crc, ubyte[] buf) {
		uint c = crc;
		int n;

		if (!crc_table_computed)
			make_crc_table();

		for (n = 0; n < buf.length; n++) {
			c = this.crc_table[(c ^ buf[n]) & 0xff] ^ (c >> 8);
		}

		return c;
	}

	static uint crc(ubyte[] buf) {
		return update_crc(0xffffffff, buf) ^ 0xffffffff;
	}

}