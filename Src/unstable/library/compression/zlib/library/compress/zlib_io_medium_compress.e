note
	description: "[
			Implements basic output stream as a stream filtered by the zlib compression
			algorithms. Target IO_MEDIUM.
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	ZLIB_IO_MEDIUM_COMPRESS
inherit

	ZLIB_COMPRESS

create
	io_medium_stream

feature -- Initialization

	io_medium_stream (a_medium: IO_MEDIUM)
		require
			not_connected: not is_connected
			non_void_medium: a_medium /= Void
			medium_open_read_write: a_medium.is_open_read and then a_medium.is_open_write
		do
			make
			intialize
			io_medium := a_medium
		ensure
			medium_set: attached io_medium
		end

feature -- Deflate

	put_io_medium (a_medium: IO_MEDIUM)
			-- Deflate the medium content.
		require
			open_read: a_medium.is_open_read

		do
			user_input_io_medium := a_medium
			deflate
			if attached user_input_io_medium as l_medium then
				l_medium.close
			end
			close
		end

feature -- Access

	is_connected: BOOLEAN
			-- <Precursor>
		do
			Result := attached io_medium
		end

feature {NONE} -- Deflate implementation		

	read: INTEGER
			-- <Precursor>
		do
			if attached user_input_io_medium as l_input_medium then
				Result := io_medium_read (l_input_medium)
			end
		end

	write (a_amount: INTEGER): INTEGER
			-- <Precursor>
		do
			if attached io_medium as l_medium then
				Result := io_medium_write (output_buffer,a_amount,l_medium)
			end
		end

	close
			-- <Precursor>
		do
			if attached io_medium as l_medium then
				l_medium.close
			end
		end

	io_medium_read (a_medium: IO_MEDIUM): INTEGER
			-- Read the medium by character until end of string or the number of elements (Chunk) was reached.
			-- Return the number of elements read.
		local
			l_index: INTEGER
			l_string: STRING
		do
			a_medium.read_stream (Chunk)
			l_string := a_medium.last_string
			from
				l_index := 1
			until
				l_index > l_string.count
			loop
				input_buffer.put_character (l_string.at (l_index), l_index - 1)
				l_index := l_index + 1
			end
			if l_string.count < Chunk then
				end_of_input := True
			end
			Result := l_index - 1
		end

	io_medium_write  (a_buffer: MANAGED_POINTER; a_amount: INTEGER; a_dest: IO_MEDIUM): INTEGER
		local
			l_index: INTEGER
		do
			from
				l_index := 1
			until
				l_index > a_amount or l_index > a_buffer.count
			loop
				a_dest.put_character (a_buffer.read_character (l_index - 1))
				l_index := l_index + 1
			end
			Result := l_index - 1
		end


feature {NONE} -- Implementation

	io_medium: detachable IO_MEDIUM
		-- Medium used to write the compressed ouput

	user_input_io_medium: detachable IO_MEDIUM
		-- Content to compress	

end