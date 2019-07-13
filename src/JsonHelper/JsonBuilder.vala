/*
* Copyright (c) {{yearrange}} Alex ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alex Angelou <>
*/

using DataHelper;
using Json;

namespace JsonHelper {

    public Json.Node get_address_list_with_type (List<DataWithType<Address?>>? list) {
        var builder = new Json.Builder ();

        builder.begin_array ();
        if (list != null) {
            foreach (var data in list) {
                builder.add_value (get_address_with_type (data));
            }
        }

        builder.end_array ();

        return builder.get_root ();
    }

    public Json.Node get_string_list_with_type (List<DataWithType<string>>? list) {
        var builder = new Json.Builder ();

        builder.begin_array ();
        if (list != null) {
            foreach (var data in list) {
                print (@"$(data.data) ($(data.type))");
                builder.add_value (get_string_with_type (data));
            }
        }

        builder.end_array ();

        return builder.get_root ();
    }

    public Json.Node get_string_list (List<string>? list) {
        var builder = new Json.Builder ();

        builder.begin_array ();
        if (list != null) {
            foreach (var data in list) {
                builder.add_string_value (data);
            }
        }

        builder.end_array ();

        return builder.get_root ();
    }

    public Json.Node get_date (Date? date) {
        var builder = new Json.Builder ();
        builder.begin_object ();
        if (date != null) {
            builder.set_member_name ("day");
            builder.add_int_value (date.get_day ());

            builder.set_member_name ("month");
            builder.add_int_value (date.get_month ());

            builder.set_member_name ("year");
            builder.add_int_value (date.get_year ());
        }
        builder.end_object ();

        return builder.get_root ();
    }

    private Json.Node get_address (Address? address) {
        var builder = new Json.Builder ();
        builder.begin_object ();
        if (address != null) {
            builder.set_member_name ("street");
            builder.add_string_value (address.street);

            builder.set_member_name ("city");
            builder.add_string_value (address.city);

            builder.set_member_name ("state");
            builder.add_string_value (address.state);
            builder.set_member_name ("zip");
            builder.add_string_value (address.zip);

            builder.set_member_name ("country");
            builder.add_string_value (address.country);
        }
        builder.end_object ();

        return builder.get_root ();
    }

    private Json.Node get_string_with_type (DataWithType<string> data) {
        var builder = new Json.Builder ();
        builder.begin_object ();

        builder.set_member_name ("data");
        builder.add_string_value (data.data);

        builder.set_member_name ("type");
        builder.add_string_value (data.type.to_string ());

        builder.end_object ();

        return builder.get_root ();
    }

    private Json.Node get_address_with_type (DataWithType<Address?> data) {
        var builder = new Json.Builder ();
        builder.begin_object ();

        builder.set_member_name ("data");
        builder.add_value (get_address (data.data));

        builder.set_member_name ("type");
        builder.add_string_value (data.type.to_string ());

        builder.end_object ();

        return builder.get_root ();
    }
}
