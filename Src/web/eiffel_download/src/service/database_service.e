note
	description: "Summary description for {DATABASE_SERVICE}."
	date: "$Date$"
	revision: "$Revision$"

class

	DATABASE_SERVICE

create
	make

feature {NONE} -- Initialize

	make (a_connection: DATABASE_CONNECTION)
			-- Create the API service
		require
			is_connected: a_connection.is_connected
		do
			create data_provider.make (a_connection)
			create login_provider.make (a_connection)
		end

feature -- Access


	is_membership (a_email: READABLE_STRING_32) : BOOLEAN
			-- Is email `a_email' already associated to a Membership user?
		do
			Result := attached login_provider.user_from_email (a_email)
		end

	is_contact (a_email: READABLE_STRING_32) : BOOLEAN
			-- Is email `a_email' already associated to a Contact user?
		do
			Result := attached login_provider.contact_from_email (a_email)
		end

	is_new_contact (a_email: READABLE_STRING_32) : BOOLEAN
			-- Email `a_email' does not exist in the database.
		do
			Result := not ( is_membership(a_email) or is_contact(a_email) )
		end

	is_download_active (a_email: READABLE_STRING_32; a_token: READABLE_STRING_32): BOOLEAN
			-- Is download active for email `a_email' and token `a_token' and `a_platform'?
		local
			l_result: INTEGER
		do
			l_result := data_provider.download_expiration_token_age (a_token, a_email)
			if
				l_result >= 0 and then
		        l_result <= 10
		    then
		    	Result := True
		    end
		end

feature -- Basic Operations

	add_download_interaction_membership (a_email, a_product, a_platform, a_file_name, a_token: READABLE_STRING_32)
		do
			if attached login_provider.user_from_email (a_email) as l_data then
				 data_provider.add_download_interaction (l_data.user_name, a_product, a_platform, a_file_name)
			end
		end

	add_download_interaction_contact (a_email, a_product, a_platform, a_file_name, a_token: READABLE_STRING_32)
		do
			if attached login_provider.contact_from_email (a_email) then
				 data_provider.add_download_interaction_contact (a_email, a_product, a_platform, a_file_name)
			end
		end

	initialize_download (a_email, a_token, a_platform: READABLE_STRING_32)
			-- Initialize product download.
		do
			data_provider.initialize_download (a_email, a_token)
		end

	add_temporary_contact (a_first_name, a_last_name, a_email: READABLE_STRING_32; a_newsletter: INTEGER)
			-- A a new contact temporary with first_name, last_name and email.
		do
			data_provider.add_contacts_temporary (a_first_name, a_last_name, a_email, a_newsletter)
		end

	validate_contact (a_email: READABLE_STRING_32)
			-- A a new contact from a temporary contact
		do
			data_provider.add_temporary_contacts_to_contacts (a_email)
		end

	register_newsletter (a_email: READABLE_STRING_32)
			-- Register a contact with email `a_email' to the newsletter.
		do
			data_provider.register_newsletter (a_email)
		end

feature {NONE} -- Database Providers

	data_provider: REPORT_DATA_PROVIDER
			-- Report Data provider.

	login_provider: LOGIN_DATA_PROVIDER
			-- Login data provider.

end