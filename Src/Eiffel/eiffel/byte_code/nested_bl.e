﻿note
	description: "Enlarged byte code for nested call."
	legal: "See notice at end of class."
	status: "See notice at end of class."

class NESTED_BL

inherit
	NESTED_B
		redefine
			allocates_memory,
			analyze,
			c_type,
			free_register,
			generate,
			has_call,
			has_gcable_variable,
			is_temporary,
			parent,
			print_checked_target_register,
			print_register,
			propagate,
			register,
			set_parent,
			set_register,
			stored_register,
			unanalyze
		end

	SHARED_TYPE_I
		export {NONE} all end

feature

	register: REGISTRABLE
			-- In which register the expression is stored

	set_register (r: REGISTRABLE)
			-- Set current register to `r'
		do
			register := r
		end

	parent: NESTED_BL
			-- Parent of current node

	set_parent (p: NESTED_BL)
			-- Set `parent' to `p'
		do
			parent := p
		end

	c_type: TYPE_C
			-- Current C type (used by `get_register')
		do
			Result := local_type.c_type
		end

	local_type: TYPE_A
			-- Type of the current call
		require
			valid_message: message /= Void
		do
			Result := real_type (message.target.type)
		end

	has_gcable_variable: BOOLEAN
			-- Is the current call using a GCable variable ?
			-- Only the last dot is important for us.
		do
			if message.target = message then
					-- We are the last call
				Result := target.has_gcable_variable or
					message.has_gcable_variable
			else
					-- Propagate the request
				Result := message.has_gcable_variable
			end
		end

	propagate (r: REGISTRABLE)
			-- Propagates register to calls in expression whose type matches
			-- the one of the propagated entity. Anyway, the last call catches
			-- it, so that No_register may be caught too...
		do
			if message.target = message then
					-- We are the last call, hence we grab the register when
					-- the type of the target is NOT a simple type (as it will
					-- be metamorphosed and that is not an operation which can
					-- be inlined).
				if 	register = Void
					and
					local_type.c_type.same_class_type (r.c_type)
					and
					(r = No_register implies not real_type (target.type).is_basic)
					and
					(r = No_register implies context.propagate_no_register)
					and
					not context.has_invariant
				then
					register := r
					context.set_propagated
				end
			else
					-- Grab register only if it has the same type as ours
					-- and if it is not used later in the expression.
					-- We never grab temporary registers in the middle of a
					-- multidot expression.
				if not (r.is_temporary or used (r)) then
					if
						local_type.c_type.same_class_type (r.c_type) and then
						register = Void and
						not context.has_invariant
					then
							-- Don't bother calling set_propagated, because we
							-- know it'll be done at the end of the call anyway.
						register := r
					end
						-- We may safely propagate register to our target only
						-- when that register is not used further in the call.
						-- If r is No_register, make sure the target is NOT an
						-- attribute. then that it is not polymorphic, otherwise
						-- we would call an Eiffel function to evaluate the
						-- Current AND the Dtype of the expression, which we
						-- cannot do--RAM.
					if 	r /= No_register
						or else
							(	(not target.is_attribute)
								and
								(not target.is_polymorphic)
								and
								context.propagate_no_register)
					then
						target.propagate (r)
					end
				end
					-- Recursively propagate register on the whole call tree
				message.propagate (r)
			end
		end

	stored_register: REGISTRABLE
			-- Register in which the call is stored (last one)
		do
			if message.target = message then
					-- We are in the last multidot cal
				Result := register
			else
				Result := message.stored_register
			end
		end

	print_register
			-- Print register or generate if there are no register.
			-- This is the last register in a multidot expression. When
			-- register is No_register, the call is not meant to be put in
			-- a temporary register, which means we have to expand the call
			-- itself.
			-- See  also `print_checked_target_register'.
		do
			if message.target = message then
					-- We reached the last call.
				if register = No_register then
						-- There is no register, which means the call has not
						-- been generated yet.
					message.target.generate_on
						(if parent = Void then
								-- This is the first call.
							target
						else
								-- This is part of a dot call. Generate a call on
								-- the entity stored in the parent's register.
							parent.register
						end)
				else
						-- There is a register, hence the call has already
						-- been generated and the result is in the register.
					register.print_register
				end
			else
					-- Simply propagate the request (it is impossible for a
					-- call which is part of a multidot expression to have
					-- its register set to No_register).
				message.print_register
			end
		end

	free_register
			-- Free register used by last call expression. If No_register was
			-- propagated, also frees the registers used by target and
			-- last message.
		do
			if message.target = message then
					-- Reached last call
				precursor {NESTED_B}
					-- Free those registers which where kept because No_register
					-- was propagated, hence call was meant to be expanded
					-- in-line.
				if register = No_register then
					target.free_register
					message.free_register
				end
			else
					-- Propagate the request
				message.free_register
			end
		end

	free_target_register
			-- Free the register used by the message target
		local
			msg_target: ACCESS_B
		do
			msg_target := message.target
			if msg_target /= message and message.register /= No_register
			then
					-- Last call was not reached. Free the next target
					-- iff not to be stored in No_register
				msg_target.free_register
			elseif msg_target = message and register /= No_register then
				msg_target.free_register
			end
		end

	unanalyze
			-- Undo the analysis of the expression
		local
			void_register: REGISTER
		do
			if parent = Void then
					-- At the top of the tree.
				target.unanalyze
			end
			message.target.unanalyze
			register := void_register
			if message.target /= message then
					-- We are not the last call on the chain.
				message.unanalyze
			end
		end

	analyze
			-- Analyze expression
		local
			msg_target: ACCESS_B
		do
			msg_target := message.target
			if parent = Void then
					-- If we are at the top of the tree hierarchy, then
					-- this has never been analyzed. If the access has
					-- no parameters, then it will be expanded in-line.
				if
					target.parameters = Void and then
						-- Make sure the target is NOT an attribute. then that
						-- it is not polymorphic, otherwise we would call an
						-- Eiffel function to evaluate the Current AND the Dtype
						-- of the expression, which we cannot do--RAM. This
						-- of course applies only when the current call is a
						-- polymorphic one...
						-- Check also that target is not a parenthesized expression
						-- that could enclose an attribute, a polymorphic call, etc.
					msg_target.parameters = Void and then
						-- This test leads to an optimization for t.f (ref).
						-- The generated_code was E_f (E_t (l[0]), ref)
						-- Possible problems for the GC depending on the order
						-- of evaluation of the parameters of a C function
						-- The C standard doesn't specify anything
						-- Problem discovered during the DOS port.
						-- The optimization can still be done for calls like t.f:
						-- E_f (E_t (l[0])) is valid and does not need a register
						-- Xavier
					not
						(target.is_attribute or else
						target.is_polymorphic or else
						msg_target.is_polymorphic or else
							-- If assertions are kept, calls cannot be arguments of each other
							-- because the flag indicating a nested call ("nstcall") should be set separately for each of them.
						message.has_call and then target.has_call and then system.keep_assertions)
				then
					context.init_propagation
					target.propagate (No_register)
				end
				target.analyze
			end
			if system.is_scoop and then real_type (target.type).is_separate then
					-- Mark current because separate calls use Current to compute client processor ID.
				context.mark_current_used
					-- Inform the context that there is a separate call.
				context.set_has_separate_call
			end
				-- Analyze the next target
			msg_target.analyze_on (target)
				-- These register will be freed by a call to free_register if
				-- register = No_register (remember: this is NOT possible in
				-- the middle of a nested call).
			if context.has_invariant then
					-- If there is some invariant checking, then we MUST take a
					-- register BEFORE freeing those used by the dot call,
					-- otherwise we would not be able to check the invariant
					-- after the call (as the variable playing 'Current' might
					-- get overwritten if re-used now).
				get_register
			end
			if register /= No_register then
				if parent = Void then
						-- First call. Otherwise, target is freed by parent.
					target.free_register
				else
						-- The register used by our parent is no longer needed.
					parent.register.free_register
				end
					-- Free the register used by the message target
				free_target_register
			end
				-- Take a register if none has been propagated
				-- The register will be freed later on (this may well be
				-- part of a parameter list).
			if not context.has_invariant then
				get_register
			end
			if msg_target /= message then
					-- We are not the last call on the chain.
				message.analyze
			end
		end

	generate
			-- Generate expression
		do
			if parent = Void then
					-- This is the first call. Generate the target.
				target.generate
					-- generate a hook
				if target.is_feature then
					generate_frozen_debugger_hook_nested
				end
						-- Generate a call on an entity stored in `target'
				generate_call (target)
			else
					-- This is part of a dot call. Generate a call on the
					-- entity stored in the parent's register.
					-- Our target is already generated.
				generate_call (parent.register)
			end
			if message.target /= message then
					-- generate a hook
				generate_frozen_debugger_hook_nested
					-- We are not the last call on the chain.
				message.generate
			end
		end

	generate_call (reg: REGISTRABLE)
			-- Generate a call on entity held in `reg'
		local
			l_type: TYPE_A
			message_target: ACCESS_B
		do
				-- Message_target is the target of the message (if message is a nested_bl) and message otherwise.
			message_target := message.target
				-- Put parameters, if any, in temporary registers
			message_target.generate_parameters (reg)
			if register /= No_register then
					-- If register is No_register, then the call will be
					-- generated directly by a call to `print_register'.
					-- Otherwise, we have to generate it now.
				l_type := real_type (target.type)
				message_target.generate_call (system.is_scoop and then l_type.is_separate, False, False, register, reg)
			end
		end

	has_call: BOOLEAN = True
			-- The expression has at least one call

	allocates_memory: BOOLEAN
			-- <Precursor>
		do
			Result :=
				context.has_invariant or else
				target.allocates_memory or else
				message.target.allocates_memory or else
				message.allocates_memory
		end

	is_temporary: BOOLEAN
			-- <Precursor>
		do
			if message.target /= message then
				Result := message.is_temporary
			elseif register /= No_register then
				Result := register.is_temporary
			end
		end

feature {REGISTRABLE} -- C code generation

	print_checked_target_register
			-- <Precursor>
		do
			if message.target = message then
					-- We reached the last call
				if register = No_register then
						-- There is no register, which means the call has not
						-- been generated yet.
						-- General case.
					Precursor
				else
						-- There is a register, hence the call has already
						-- been generated and the result is in the register.
					register.print_checked_target_register
				end
			else
					-- Simply propagate the request (it is impossible for a
					-- call which is part of a multidot expression to have
					-- its register set to No_register).
				message.print_checked_target_register
			end
		end

note
	copyright:	"Copyright (c) 1984-2020, Eiffel Software"
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
