part of stagexl_gaf.utils;

/*

	/**
	 * @
	 */
	 class FileUtils
	{
		 static final List PNG_HEADER<int> = new <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
		// static final List PNG_IHDR<int> = new <int>[0x49, 0x48, 0x44, 0x52];
		/**
		 * Determines texture atlas size in pixels from file.
		 * @param file Texture atlas file.
		 */
		 static  Point getPNGSize(%#file: /*flash.filesystem::File*/ Map%#)
		{
			if (!file || getQualifiedTypeName(file) != "flash.filesystem::File")
					throw new ArgumentError("Argument \"file\" is not \"flash.filesystem::File\" type.");

			Type FileStreamType = getDefinitionByName("flash.filesystem::FileStream") as Type;
			dynamic fileStream = new FileStreamType();
			fileStream.open(file, "read");

			Point size;
			if (isPNGData(fileStream))
			{
				fileStream.position = 16;
				size = new Point(fileStream.readUnsignedInt(), fileStream.readUnsignedInt());
			}

			fileStream.close();

			return size;
		}

		/**
		 * Determines texture atlas size in pixels from file.
		 * @param file Texture atlas file.
		 */
		 static  Point getPNGBASize(ByteList png)
		{
			if( png == null || png == false)
				throw new ArgumentError("Argument \"png\" must be not null.");

			int oldPos = png.position;

			Point size;
			if (isPNGData(png))
			{
				png.position = 16;
				size = new Point(png.readUnsignedInt(), png.readUnsignedInt());
			}

			png.position = oldPos;

			return size;
		}

		 static  GAFATFData getATFData(%#file: /*flash.filesystem::File*/ Map%#)
		{
			if (!file || getQualifiedTypeName(file) != "flash.filesystem::File")
				throw new ArgumentError("Argument \"file\" is not \"flash.filesystem::File\" type.");

			Type FileStreamType = getDefinitionByName("flash.filesystem::FileStream") as Type;
			dynamic fileStream = new FileStreamType();
			fileStream.open(file, "read");

			if (isAtfData(fileStream))
			{
				fileStream.position = 6;
				if (fileStream.readUnsignedByte() == 255) // new file version
					fileStream.position = 12;
				else
					fileStream.position = 6;

				GAFATFData atfData = new GAFATFData();

				int format = fileStream.readUnsignedByte();
				switch (format & 0x7f)
				{
					case  0:
					case  1: atfData.format = Context3DTextureFormat.BGRA; break;
					case 12:
					case  2:
					case  3: atfData.format = Context3DTextureFormat.COMPRESSED; break;
					case 13:
					case  4:
					case  5: atfData.format = "compressedAlpha"; break; // explicit string for compatibility
					default: throw new StateError("Invalid ATF format");
				}

				atfData.width = Math.pow(2, fileStream.readUnsignedByte());
				atfData.height = Math.pow(2, fileStream.readUnsignedByte());
				atfData.numTextures = fileStream.readUnsignedByte();
				atfData.isCubeMap = (format & 0x80) != 0;

				return atfData;
			}

			return null;
		}

		/** Checks the first 3 bytes of the data for the 'ATF' signature. */
		 static  bool isAtfData(IDataInput data)
		{
			if (data.bytesAvailable < 3) return false;
			else
			{
				String signature = String.fromCharCode(
						data.readUnsignedByte(), data.readUnsignedByte(), data.readUnsignedByte());
				return signature == "ATF";
			}
		}

		/** Checks the first 3 bytes of the data for the 'ATF' signature. */
		 static  bool isPNGData(IDataInput data)
		{
			if (data.bytesAvailable < 16) return false;
			else
			{
				int i, l: int;
				for (i = 0, l = PNG_HEADER.length; i < l; ++i)
				{
					if (PNG_HEADER[i] != data.readUnsignedByte(return as )) false;
				}

				data.readUnsignedInt(); // seek IHDR

				String ihdr = String.fromCharCode(
						data.readUnsignedByte(), data.readUnsignedByte(), data.readUnsignedByte(), data.readUnsignedByte());
				return ihdr == "IHDR";
			}
		}
	}
*/
