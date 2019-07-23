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
using Model;
using Json;

namespace JsonHelper {

    private class JsonDateModel : GLib.Object {
        public int day {get; set;}
        public int month {get; set;}
        public int year {get; set;}

        public Date? to_date () {
            var date = Date ();
            date.set_dmy ((DateDay) day, month, (DateYear) year);
            return date;
        }
    }

    private class JsonAddressModel : GLib.Object {
        public string street {get; set;}
        public string city {get; set;}
        public string state {get; set;}
        public string zip {get; set;}
        public string country {get; set;}

        public bool valid {
            get {
                return street != null && city != null && state != null && zip != null && country != null;
            }
        }

        public Address? to_address () {
            if (!valid)
                return null;

            return Address () {
                street = street.locale_to_utf8 (-1, null, null),
                city = city.locale_to_utf8 (-1, null, null),
                state = state.locale_to_utf8 (-1, null, null),
                zip = zip.locale_to_utf8 (-1, null, null),
                country = country.locale_to_utf8 (-1, null, null)
            };
        }
    }

    private class JsonContactModel : GLib.Object {
        public string name {get; set;}
        public string? icon {get; set;}
        public JsonDateModel? birthday {get; set;}
        public JsonDateModel? anniversary {get; set;}

        // GObject Deserialize won't dedserialize arrays :(

        public Contact to_contact () {
            var contact = new Contact (name.locale_to_utf8 (-1, null, null));

            if (icon != null? icon != "" : false) {
                var data = Base64.decode (icon);
                contact.icon = new Gdk.Pixbuf.from_data (data, Gdk.Colorspace.RGB, true, 8, 64, 64, 150);
            }

            if (birthday != null) {
                contact.birthday = birthday.to_date ();
            }

            if (birthday != null) {
                contact.anniversary = anniversary.to_date ();
            }

            return contact;
        }
    }

    private class JsonDWTStringModel : GLib.Object {
        public string data {get; set;}
        public string data_type {get; set;}

        public DataWithType<string> to_dwt () {
            return new DataWithType<string> (data.locale_to_utf8 (-1, null, null), DataHelper.Type.parse (data_type));
        }
    }

    private class JsonDWTAddressModel : GLib.Object {
        public JsonAddressModel data {get; set;}
        public string data_type {get; set;}

        public DataWithType<Address?> to_dwt () {
            return new DataWithType<Address?> (data.to_address (), DataHelper.Type.parse (data_type));
        }
    }

    public Contact? parse (string json) throws Error
        requires (json != null)
    {
        print (json + "\n");

        var parser = new Json.Parser ();
        parser.load_from_data (json);

        var node = parser.get_root ();
        assert (node.get_node_type () == Json.NodeType.OBJECT);

        var obj = Json.gobject_deserialize (typeof (JsonContactModel), node) as JsonContactModel;
        assert (obj != null);

        var contact = obj.to_contact ();

        var member_table = new HashTable<string, Json.Array> (str_hash, str_equal);

        node.get_object ().foreach_member ((object, name, member_node) => {
            if (member_node.get_node_type () == Json.NodeType.ARRAY) {
                member_table.insert (name, member_node.get_array ());
            }
        });

        if (member_table.contains ("phones")) {
            var phones_jarray = member_table.get ("phones");
            if (contact.phones == null) contact.phones = new List<DataWithType<string>> ();
            phones_jarray.foreach_element ((array, i, node) => {
                var data = Json.gobject_deserialize (typeof (JsonDWTStringModel), node) as JsonDWTStringModel;
                contact.phones.append (data.to_dwt ());
            });
        }

        if (member_table.contains ("emails")) {
            var emails_jarray = member_table.get ("emails");
            if (contact.emails == null) contact.emails = new List<DataWithType<string>> ();
            emails_jarray.foreach_element ((array, i, node) => {
                var data = Json.gobject_deserialize (typeof (JsonDWTStringModel), node) as JsonDWTStringModel;
                contact.emails.append (data.to_dwt ());
            });
        }

        if (member_table.contains ("addresses")) {
            var addresses_jarray = member_table.get ("addresses");
            if (contact.addresses == null) contact.addresses = new List<DataWithType<Address?>> ();
            addresses_jarray.foreach_element ((array, i, node) => {
                var data = Json.gobject_deserialize (typeof (JsonDWTAddressModel), node) as JsonDWTAddressModel;
                contact.addresses.append (data.to_dwt ());
            });
        }

        if (member_table.contains ("notes")) {
            var notes_jarray = member_table.get ("notes");
            if (contact.notes == null) contact.notes = new List<string> ();
            notes_jarray.foreach_element ((array, i, node) => {
                var data = new Reader (node).get_string_value ();
                contact.notes.append (data);
            });
        }

        if (member_table.contains ("websites")) {
            var websites_jarray = member_table.get ("websites");
            if (contact.websites == null) contact.websites = new List<string> ();
            websites_jarray.foreach_element ((array, i, node) => {
                var data = new Reader (node).get_string_value ();
                contact.websites.append (data);
            });
        }

        if (member_table.contains ("nicknames")) {
            var nicknames_jarray = member_table.get ("nicknames");
            if (contact.nicknames == null) contact.nicknames = new List<string> ();
            nicknames_jarray.foreach_element ((array, i, node) => {
                var data = new Reader (node).get_string_value ();
                contact.nicknames.append (data);
            });
        }

        return contact;
    }

}
