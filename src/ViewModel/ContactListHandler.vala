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

    public class ContactListHandler : Object {

        public signal void changed ();

        private ContactList contact_list = new ContactList ();

        private int _i = 0;

        public uint length {
            get {
                return contact_list.data.length ();
            }
        }

        public void initialize () throws Error {
            var paths = FileHelper.get_contact_files ();
            if (paths.length () == 0) return;

            foreach (var path in paths) {
                var contact = load (path);
                contact.remove.connect (() => remove_contact (contact));
                contact_list.data.insert_sorted (contact, compare_contacts);
            }

            changed ();
        }

        public void import_from_folks () throws Error {
            async_folks_initialize.begin ();
        }

        private async void async_folks_initialize () throws Error {
            yield FolksHelper.load ((contact) => {
                add_contact_from_model (contact);
            });
            return;
        }

        private GLib.CompareFunc<Model.Contact>? compare_contacts = (c1, c2) => {
            return strcmp (c1.name, c2.name);
        };

        public ContactHandler get_contact(int index)
            requires (index >= 0 && index < contact_list.data.length ())
        {
            return new ContactHandler.from_model (contact_list.data.nth_data (index));
        }

        public void add_contact (string name) {
            var contact = new Contact (name);
            add_contact_from_model (contact);
        }

        public void add_contact_by_handler (ContactHandler handler) {
            var contact = handler.contact;
            add_contact_from_model (contact);
        }

        private void add_contact_from_model (Contact contact) {
            contact.remove.connect (() => remove_contact (contact));

            contact_list.data.insert_sorted (contact, compare_contacts);
            changed ();
        }

        public bool remove_contact (Contact contact) {
            if (!contains (contact)) return false;

            contact_list.data.remove (contact);

            changed ();
            return true;
        }

        public List<int> search (string needle) {
            List<int> indexes = new List<int> ();
            for (var i=0; i<contact_list.data.length (); i++) {
                var contact = contact_list.data.nth_data (i);
                if (contact.name.casefold ().contains (needle.down ()))
                    indexes.append (i);
            }
            return indexes;
        }

        public bool contains (Contact input_contact) {
            foreach (var contact in contact_list.data) {
                if (contact == input_contact)
                    return true;
            }
            return false;
        }

        public Contact load (string path) throws Error {
            var contact = JsonHelper.parse (FileHelper.read (path));
            return contact;
        }

        public string export () {
            return VCardHelper.build_list (contact_list.data);
        }

        public void import (string path) throws Error {
            var list = VCardHelper.parse (path);
            foreach (var contact in list) {
                contact.remove.connect (() => remove_contact (contact));

                contact_list.data.insert_sorted (contact, compare_contacts);
            }
            changed ();
        }

        public ContactListHandler iterator () {
            _i = 0;
            return this;
        }

        public ContactHandler? next_value () {
            if (contact_list.data.length () <= _i)
                return null;

            return new ContactHandler.from_model (contact_list.data.nth_data (_i++));
        }

    }

}
