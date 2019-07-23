/*
* Copyright (c) {{yearrange}} Alex Angelou ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNEs FOR A PARTICULAR PURPOsE.  see the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free software Foundation, Inc., 51 Franklin street, Fifth Floor,
* Boston, MA 02110-1301 UsA
*
* Authored by: Alex Angelou <>
*/

using Model;
using DataHelper;
using Folks;

namespace FolksHelper {

    public delegate void ContactActionFunc (Contact contact);

    public async void load (ContactActionFunc actions) throws Error {
        var aggregator = IndividualAggregator.dup ();

        aggregator.individuals_changed_detailed.connect ((changes) => {
            foreach (var individual in changes.get (null)) {
                actions (build_contact_from_individual (individual));
            }
        });

        foreach (var individual in aggregator.individuals.values) {
            actions (build_contact_from_individual (individual));
        }

        yield aggregator.prepare ();
    }

    private Contact build_contact_from_individual (Individual individual) {
        var contact = new Contact (individual.display_name);

        foreach (var phone in individual.phone_numbers) {
            var type = parse_type (phone.get_parameter_values ("type"));
            contact.phones.append (new DataWithType<string> (phone.value, type));
        }

        foreach (var email in individual.email_addresses) {
            var type = parse_type (email.get_parameter_values ("type"));
            contact.emails.append (new DataWithType<string> (email.value, type));
        }

        foreach (var address in individual.postal_addresses) {
            var type = parse_type (address.get_parameter_values ("type"));
            contact.addresses.append (new DataWithType<Address?> (parse_address (address.value), type));
        }

        foreach (var note in individual.notes) {
            contact.notes.append (note.value);
        }

        foreach (var website in individual.urls) {
            contact.websites.append (website.value);
        }

        contact.nicknames.append (individual.alias);

        if (individual.birthday != null) {
            int day;
            int month;
            int year;
            individual.birthday.get_ymd (out year, out month, out day);
            contact.birthday = Date ();
            contact.birthday.set_dmy ((DateDay) day, month, (DateYear) year);
        }

        //TODO icon
        return contact;
    }

    private Address parse_address (PostalAddress p_address) {
        return Address () {
            street = p_address.street == ""? null: p_address.street,
            city = p_address.locality == ""? null: p_address.locality,
            state = p_address.region == ""? null: p_address.region,
            zip = p_address.postal_code == ""? null: p_address.postal_code,
            country = p_address.postal_code == ""? null: p_address.country
        };
    }

    private DataHelper.Type parse_type (Gee.Collection<string>? type_collection) {
        foreach (var type_string in type_collection) {
            switch (type_string) {
                case AbstractFieldDetails.PARAM_TYPE_HOME:
                    return DataHelper.Type.HOME;
                case AbstractFieldDetails.PARAM_TYPE_WORK:
                    return DataHelper.Type.WORK;
                case AbstractFieldDetails.PARAM_TYPE_OTHER:
                    return DataHelper.Type.OTHER;
            }
        }
        return DataHelper.Type.DEFAULT;
    }

}
