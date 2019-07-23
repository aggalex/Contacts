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
using Gdk;

using DataHelper;

namespace ViewModel {

    public class ContactHandler {

        public signal void changed ();
        internal Contact contact;

        public string name {
            get {
                return contact.name;
            }
            set {
                contact.name = value;
                changed ();
            }
        }

        public Date? birthday {
            get {
                return contact.birthday;
            }
            set {
                contact.birthday = value;
                changed ();
            }
        }

        public Date? anniversary {
            get {
                return contact.anniversary;
            }
            set {
                contact.anniversary = value;
                changed ();
            }
        }

        public Pixbuf icon {
            get {
                return contact.icon;
            }
            set {
                var image = value;

                if (image.width < image.height) {
                    int y = image.height/2 - image.width/2;
                    image = new Gdk.Pixbuf.subpixbuf (image, 0, y, image.width, image.width);
                } else if (image.width > image.height) {
                    int x = image.width/2 - image.height/2;
                    image = new Gdk.Pixbuf.subpixbuf (image, x, 0, image.height, image.height);
                }

                if (image.width != 64)
                    image = image.scale_simple (64, 64, Gdk.InterpType.HYPER);

                contact.icon = image;
                changed ();
            }
        }

        public List<DataWithType<string>>? phones {
            get {
                return contact.phones;
            }
        }

        public List<DataWithType<string>>? emails {
            get {
                return contact.emails;
            }
        }

        public List<DataWithType<Address?>>? addresses {
            get {
                return contact.addresses;
            }
        }

        public List<string>? notes {
            get {
                return contact.notes;
            }
        }


        public List<string>? websites {
            get {
                return contact.websites;
            }
        }

        public List<string>? nicknames {
            get {
                return contact.nicknames;
            }
        }




        public ContactHandler (string name = "") {
            contact = new Contact (name);
        }

        public ContactHandler.from_model (Contact contact) {
            this.contact = contact;
        }



        public void add_phone (string phone, DataHelper.Type type) {
            if (contact.phones == null)
                contact.phones = new List<DataWithType<string>>();

            contact.phones.append(new DataWithType<string> (phone, type));
            changed ();
        }

        public bool set_phone (string phone, DataHelper.Type type, int index) {
            if (contact.phones == null) return false;

            unowned List<DataWithType<string>> element = contact.phones.nth (index);
            element.data.data = phone;
            element.data.type = type;
            try {
                return true;
            } finally {
                changed ();
            }
        }

        public void remove_phone(int index) {
            if (contact.phones.length () == 1) {
                contact.phones = null;
                return;
            }
            contact.phones.remove(contact.phones.nth_data(index));
            changed ();
        }




        public void add_email (string email, DataHelper.Type type) {
            if (contact.emails == null)
                contact.emails = new List<DataWithType<string>>();
            contact.emails.append (new DataWithType<string> (email, type));
            changed ();
        }

        public bool set_email (string email, DataHelper.Type type, int index) {
            if (contact.emails == null) return false;

            unowned List<DataWithType<string>> element = contact.emails.nth (index);
            element.data.data = email;
            element.data.type = type;
            try {
                return true;
            } finally {
                changed ();
            }
        }

        public void remove_email(int index) {
            if (contact.emails.length () == 1) {
                contact.emails = null;
                return;
            }

            contact.emails.remove(contact.emails.nth_data(index));
            changed ();
        }




        public void add_address (Address address, DataHelper.Type type) {
            if (contact.addresses == null)
                contact.addresses = new List<DataWithType<Address?>>();
            contact.addresses.append (new DataWithType<Address?> (address, type));
            changed ();
        }

        public bool set_address (Address address, DataHelper.Type type, int index) {
            if (contact.addresses == null) return false;

            unowned List<DataWithType<Address?>> element = contact.addresses.nth (index);
            element.data.data = address;
            element.data.type = type;
            try {
                return true;
            } finally {
                changed ();
            }
        }

        public void remove_address(int index) {
            if (contact.addresses.length () == 1) {
                contact.addresses = null;
                return;
            }
            contact.addresses.remove(contact.addresses.nth_data(index));
            changed ();
        }




        public void add_note (string note) {
            print ("CREATING A NOTE");
            if (contact.notes == null)
                contact.notes = new List<string>();
            contact.notes.append (note);
            changed ();
        }

        public bool set_note (string note, int index) {
            if (contact.notes == null) return false;

            contact.notes.nth (index).data = note;
            try {
                return true;
            } finally {
                changed ();
            }
        }

        public void remove_note(int index) {
            if (contact.notes.length () == 1) {
                contact.notes = null;
                return;
            }

            contact.notes.remove(contact.notes.nth_data(index));
            changed ();
        }




        public void add_nickname (string nickname) {
            if (contact.nicknames == null)
                contact.nicknames = new List<string>();
            contact.nicknames.append (nickname);
            changed ();
        }

        public bool set_nickname (string nickname, int index) {
            if (contact.nicknames == null) return false;

            contact.nicknames.nth (index).data = nickname;
            try {
                return true;
            } finally {
                changed ();
            }
        }

        public void remove_nickname(int index) {
            if (contact.nicknames.length () == 1) {
                contact.nicknames = null;
                return;
            }

            contact.nicknames.remove(contact.nicknames.nth_data(index));
            changed ();
        }




        public void add_website (string webiste) {
            if (contact.websites == null)
                contact.websites =  new List<string>();
            contact.websites.append (webiste);
            changed ();
        }

        public bool set_website (string website, int index) {
            if (contact.websites == null) return false;

            contact.websites.nth (index).data = website;
            try {
                return true;
            } finally {
                changed ();
            }
        }

        public void remove_website(int index) {
            if (contact.websites.length () == 1) {
                contact.websites = null;
                return;
            }

            contact.websites.remove(contact.websites.nth_data(index));
            changed ();
        }




        public void save () throws Error{
            contact.save ();
        }

        public void remove () {
            contact.remove ();
        }

        public string export () {
            return VCardHelper.build (contact);
        }

    }

}
