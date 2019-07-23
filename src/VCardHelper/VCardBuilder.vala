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

namespace VCardHelper {

    public string build (Contact contact, out bool could_build_icon = null) {
        var builder = new StringBuilder ("BEGIN:VCARD\nVERSION:3.0\n");

        builder.append (build_name (contact.name));

        if (contact.birthday != null) builder.append (build_birthday (contact.birthday));
        if (contact.anniversary != null) builder.append (build_anniversary (contact.anniversary));
        try {
            if (contact.icon != null) builder.append (build_icon (contact.icon));
            could_build_icon = true;
        } catch (Error e) {
            could_build_icon = false;
        }

        foreach (var phone in contact.phones)
            builder.append (build_phone (phone));

        foreach (var email in contact.emails)
            builder.append (build_email (email));

        foreach (var address in contact.addresses)
            builder.append (build_address (address));

        foreach (var note in contact.notes)
            builder.append (build_note (note));

        foreach (var website in contact.websites)
            builder.append (build_website (website));

        foreach (var nickname in contact.nicknames)
            builder.append (build_nickname (nickname));

        builder.append ("END:VCARD");
        return builder.str;
    }

    private string build_name (string name) {
        var builder = new StringBuilder ("");

        builder.append ("N;CHARSET=UTF-8:");
        builder.append (name);
        builder.append (";;;;\n");

        builder.append ("FN;CHARSET=UTF-8:");
        builder.append (name);
        builder.append ("\n");

        return builder.str;
    }

    private string build_icon (Gdk.Pixbuf icon) throws Error {
        uint8[] buffer;
        icon.save_to_buffer (out buffer, "jpeg");
        string buffer_b64 = Base64.encode (buffer);

        var builder = new StringBuilder ("PHOTO;ENCODING=b;TYPE=JPEG:");
        builder.append (buffer_b64);
        builder.append ("\n");

        return builder.str;
    }

    private string build_birthday (Date bday) {
        var day = bday.get_day ();
        var month = bday.get_month ();
        var year = bday.get_year ();

        var builder = new StringBuilder ("BDAY;CHARSET=UTF-8:");
        builder.append (year.to_string ());
        if (month < 10) builder.append ("0");
        builder.append (((int) month).to_string ());
        if (day < 10) builder.append ("0");
        builder.append (day.to_string ());
        builder.append ("\n");

        return builder.str;
    }

    private string build_anniversary (Date anniversary) {
        var day = anniversary.get_day ();
        var month = anniversary.get_month ();
        var year = anniversary.get_year ();

        var builder = new StringBuilder ("ANNIVERSARY;CHARSET=UTF-8:");
        builder.append (year.to_string ());
        if (month < 10) builder.append ("0");
        builder.append (((int) month).to_string ());
        if (day < 10) builder.append ("0");
        builder.append (day.to_string ());
        builder.append ("\n");

        return builder.str;
    }

    private string build_phone (DataWithType<string> data) {
        var builder = new StringBuilder ("TEL;TYPE=");
        builder.append (data.type.to_string ().up ());
        builder.append (":");
        builder.append (data.data);
        builder.append ("\n");

        return builder.str;
    }

    private string build_email (DataWithType<string> data) {
        var builder = new StringBuilder ("EMAIL;CHARSET=UTF-8;TYPE=");
        builder.append (data.type.to_string ().up ());
        builder.append (",INTERNET:");
        builder.append (data.data);
        builder.append ("\n");

        return builder.str;
    }

    private string build_address (DataWithType<Address?> data) {
        var builder = new StringBuilder ("ADR;CHARSET=UTF-8;TYPE=");
        builder.append (data.type.to_string ().up ());
        builder.append (":;");
        foreach (var field in data.data.to_string_array ()) {
            builder.append (";");
            builder.append (field);
        }
        builder.append ("\n");

        return builder.str;
    }

    private string build_note (string data) {
        var builder = new StringBuilder ("NOTE;CHARSET=UTF-8:");
        builder.append (data);
        builder.append ("\n");

        return builder.str;
    }

    private string build_nickname (string data) {
        var builder = new StringBuilder ("NICKNAME;CHARSET=UTF-8:");
        builder.append (data);
        builder.append ("\n");

        return builder.str;
    }

    private string build_website (string data) {
        var builder = new StringBuilder ("URL;CHARSET=UTF-8:");
        builder.append (data);
        builder.append ("\n");

        return builder.str;
    }

    public string build_list (List<Contact> contact_list) {
        var builder = new StringBuilder ("");
        foreach (var contact in contact_list) {
            builder.append (build (contact));
            builder.append ("\n\n");
        }
        return builder.str;
    }

}
