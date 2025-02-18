﻿note
	description: "Optimized byte code for loops."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class OPT_LOOP_B

inherit
	LOOP_B
		redefine
			enlarged, size,
			pre_inlined_code
		end

feature -- Access

	enlarged: OPT_LOOP_BL
		do
			create Result
			Result.fill_from (Current)
		end

	add_array_to_generate (arr_desc: INTEGER)
		do
			if array_desc = Void then
				create array_desc.make
			end
			array_desc.extend (arr_desc)
		end

	array_desc: TWO_WAY_SORTED_SET [INTEGER]

	add_offset_to_generate (arr_desc: INTEGER)
		do
			if generated_offsets = Void then
				create generated_offsets.make
			end
			generated_offsets.extend (arr_desc)
		end

	generated_offsets: TWO_WAY_SORTED_SET [INTEGER]

	add_offset_already_generated (arr_desc: INTEGER)
		do
			if already_generated_offsets = Void then
				create already_generated_offsets.make
			end
			already_generated_offsets.extend (arr_desc)
		end

	already_generated_offsets: TWO_WAY_SORTED_SET [INTEGER]

feature -- Inlining

	size: INTEGER
		do
				-- Inlining will not be done if the feature optimizes array access.
			Result := {LACE_I}.inlining_threshold
		end

	pre_inlined_code: like Current
			-- This should NEVER be called!!!
			-- (size is bigger than maximum)
		do
		end

note
	copyright:	"Copyright (c) 1984-2019, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end
