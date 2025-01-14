note
	description: "Visitor to visit a criterion"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	QL_CRITERION_VISITOR

feature -- Process

	process_criterion (a_cri: QL_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_binary_criterion (a_cri: QL_BINARY_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_unary_criterion (a_cri: QL_UNARY_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_not_criterion (a_cri: QL_NOT_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_and_criterion (a_cri: QL_AND_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_or_criterion (a_cri: QL_OR_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_criterion_adapter (a_cri: QL_CRITERION_ADAPTER)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_compiled_imp_criterion (a_cri: QL_ITEM_IS_COMPILED_CRI_IMP)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_intrinsic_domain_criterion (a_cri: QL_INTRINSIC_DOMAIN_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

	process_domain_criterion (a_cri: QL_DOMAIN_CRITERION)
			-- Process `a_cri'.
		require
			a_cri_attached: a_cri /= Void
		deferred
		end

note
	copyright: "Copyright (c) 1984-2013, Eiffel Software"
	license: "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options: "http://www.eiffel.com/licensing"
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
