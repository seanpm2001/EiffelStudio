﻿note
	description: "Store information to be used when a conversion occurs."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	PARENT_CONVERSION_INFO

create
	make

feature {NONE} -- Initialization

	make (a_conversion: CONVERSION_INFO)
			-- Using `a_conversion' create the necessary information that is needed
			-- for checking a conversion in a descendant class.
		require
			a_conversion_not_void: a_conversion /= Void
			a_conversion_has_depend_unit: attached {FEATURE_CONVERSION_INFO} a_conversion as l_info implies l_info.has_depend_unit
		do
			if attached {FEATURE_CONVERSION_INFO} a_conversion as l_info then
				is_from_conversion := l_info.is_from_conversion
				if is_from_conversion then
						-- Unfortunately we have to duplicate, because otherwise we have
						-- a crash during incremental compilation (see eweasel test#svalid012)
						-- as well as a crash during formatting (see bug#15055).
					creation_type := l_info.target_type.actual_type.duplicate
				end
				routine_id := l_info.conversion_feature.rout_id_set.first
				class_id := l_info.conversion_class_id
			else
				check
					formal_or_null_conversion:
						attached {FORMAL_CONVERSION_INFO} a_conversion or
						attached {NULL_CONVERSION_INFO} a_conversion
				end
				is_null_conversion := True
					-- FIXME: Like above we duplicate, even though at the time of this writing we
					-- are not so sure why the type has to be duplicated.
				creation_type := a_conversion.target_type.actual_type.duplicate
			end
		end

feature -- Access

	is_null_conversion: BOOLEAN
			-- Is current conversion the null conversion, i.e. that nothing is being done
			-- to actually convert the type as it is compatible to `creation_type'.

	is_from_conversion: BOOLEAN
			-- True if conversion is of the form `create {X}.from_y (y)',
			-- False if defined as `y.to_x'.

	creation_type: TYPE_A
			-- Type use for creation when `is_from_conversion'.

	routine_id: INTEGER
			-- Routine ID of feature used for conversion.

	class_id: INTEGER
			-- Class ID of the type on which routine is called (if any).

invariant
	creation_type_not_void: is_from_conversion implies creation_type /= Void
	routine_id_positive: routine_id > 0

note
	copyright:	"Copyright (c) 1984-2017, Eiffel Software"
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
