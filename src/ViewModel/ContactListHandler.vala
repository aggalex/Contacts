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

namespace ViewModel {

    public class ContactListHandler {
 
        private ContactList contact_list = new ContactList ();

        public uint length {
            get {
                return contact_list.data.length ();
            }
        }
        private GLib.CompareFunc<Model.Contact>? compare_contacts = (c1, c2) => {
            return strcmp (c1.name, c2.name);
        };

        public ContactHandler get_contact(int index)
            requires (index >= 0 && index < contact_list.data.length ())
        {
            return new ContactHandler.from_contact (contact_list.data.nth_data (index));
        }

        public void add_contact (string name) {
            if (contact_list == null) 
                contact_list = new ContactList ();

            contact_list.data.insert_sorted (new Contact (name), compare_contacts);

        }

        public bool remove_contact (int index)
            requires (index >= 0 && index < contact_list.data.length ())
        {
            if (contact_list.data.length () == 1) {
                contact_list = null;
                return true;
            }

            contact_list.data.remove (contact_list.data.nth_data (index));
            return true;
        }

        public List<int> search (string needle) {
            List<int> indexes = new List<int> ();
            for (var i=0; i<contact_list.data.length (); i++) {
                var contact = contact_list.data.nth_data (i);
                if (contact.name.contains (needle))
                    indexes.append (i);
            }
            return indexes;
        }

    }

}
