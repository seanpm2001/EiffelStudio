note
	legal: "See notice at end of class."
	status: "See notice at end of class."

class ASSERT_ID_SET

inherit
	ARRAY [INH_ASSERT_INFO]
		rename
			make as array_create,
			put as array_put,
			count as array_count,
			force as array_force,
			empty as array_empty,
			full as array_full,
			has as array_has
		redefine
			wipe_out
		end

create
	make

feature {NONE} -- Initialization

	make (n: INTEGER)
			-- Array creation
		do
			array_create (1, n)
		end

feature -- Access

	count: INTEGER
			-- Number of routine ids present in the set

	Chunk: INTEGER = 5
			-- Array chunk

feature -- Element change

	wipe_out
			-- Clear the structure.
		do
			count := 0
			clear_all
		end

feature -- Status report

	has (assert: INH_ASSERT_INFO): BOOLEAN
			-- Is the body id `body_index' present in the set?
		local
			i: INTEGER
			b: like {INH_ASSERT_INFO}.body_index
		do
			from
				b := assert.body_index
				i := 1
			until
				i > count or else Result
			loop
				Result := item (i).body_index = b
				i := i + 1
			end
		end

	has_assert (assert: INH_ASSERT_INFO): BOOLEAN
			-- Is the `assert' in Current?
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > count or else Result
			loop
				Result := item (i).same_as (assert)
				i := i + 1
			end
		end

	has_precondition: BOOLEAN
			-- Has the set any precondition (inner or inherited)?

	has_postcondition: BOOLEAN
			-- Has the set any postcondition (inner or inherited)?

	has_class_postcondition: BOOLEAN
			-- Has the set any class postcondition (inner or inherited)?

	has_false_postcondition: BOOLEAN
			-- Has the set any false postcondition (inner or inherited)?

	has_non_object_call: BOOLEAN
			-- Are there non-object calls in preconditions or postconditions (inner or inherited)?

	has_unqualified_call: BOOLEAN
			-- Are there unqualified object calls in preconditions or postconditions (inner or inherited)?

feature -- Status Setting

	set_has_precondition (b: BOOLEAN)
			-- Set `has_precondition' to `b'.
		do
			has_precondition := b
		ensure
			has_precondition_set: has_precondition = b
		end

	set_has_postcondition (b: BOOLEAN)
			-- Set `has_postcondition' to `b'.
		do
			has_postcondition := b
		ensure
			has_postcondition_set: has_postcondition = b
		end

	set_has_class_postcondition (b: BOOLEAN)
			-- Set `has_class_postcondition' to `b'.
		do
			has_class_postcondition := b
		ensure
			has_class_postcondition_set: has_class_postcondition = b
		end

	set_has_false_postcondition (b: BOOLEAN)
			-- Set `has_false_postcondition' to `b'.
		do
			has_false_postcondition := b
		ensure
			has_false_postcondition_set: has_false_postcondition = b
		end

	set_has_non_object_call (b: BOOLEAN)
			-- Set `has_non_object_call' to `b'.
		do
			has_non_object_call := b
		ensure
			has_non_object_call_set: has_non_object_call = b
		end

	set_has_unqualified_call (b: BOOLEAN)
			-- Set `has_unqualified_call' to `b'.
		do
			has_unqualified_call := b
		ensure
			has_unqualified_call_set: has_unqualified_call = b
		end

feature -- Basic operations

	force (assert: INH_ASSERT_INFO)
			-- Insert body index `body_index' in the set if not already
			-- present. Resize the array if needed.
		do
			if not has (assert) then
					-- Routine id `body_index' is not present in the set.
				if count >= array_count then
						-- Resize needed
					conservative_resize_with_default (assert, 1, array_count + Chunk)
				end
				count := count + 1
				array_put (assert, count)
			end
		end

	merge (other: like Current)
			-- Put assert body index of `other' not present in Current.
		require
			good_argument: other /= Void
		local
			i, nb: INTEGER
		do
			from
				i := 1
				nb := other.count
			until
				i > nb
			loop
				force (other.item (i))
				i := i + 1
			end
		end

feature -- Comparison

	same_as (other: like Current): BOOLEAN
			-- Has `other' the same content than Current ?
		local
			i: INTEGER
		do
			if other /= Void and then count = other.count then
				from
					i := 1
					Result := True
				until
					i > count or else not Result
				loop
					Result := other.has_assert (item (i))
					i := i + 1
				end
			end
			debug ("ASSERTION")
				io.put_string ("same as: ")
				io.put_boolean (Result)
				io.put_new_line
				if other = Void then
					io.put_string ("other is void%N")
				elseif count /= other.count then
					io.put_string ("count is not same%N")
				end
			end
		end

note
	copyright:	"Copyright (c) 1984-2018, Eiffel Software"
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
