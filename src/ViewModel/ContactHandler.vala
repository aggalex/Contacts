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
 
        private Contact contact;

        public string name {
            get {
                return contact.name;
            }
            set {
                contact.name = value;
            }
        }

        public Date? birthday {
            get {
                if (contact.birthday == null)
                    contact.birthday = Date ();
                return contact.birthday;
            }
            set {
                contact.birthday = value;
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
            }
        }

        public ContactHandler () {
            contact = new Contact ("");
        }

        public ContactHandler.from_contact (Contact contact) {
            this.contact = contact;
        }

        public void add_phone (string phone){
            if (contact.phones == null)
                contact.phones = new List<string>();

            contact.phones.append(phone);
        }

        public void remove_phone(int index){
            if (contact.phones.length () == 1){
                contact.phones = null;
                return;
            }
            contact.phones.remove(contact.phones.nth_data(index));
        }

        public void add_email (string email){
            if (contact.emails == null)
                contact.emails = new List<string>();
            contact.emails.append (email);
        }

        public void remove_email(int index){
            if (contact.emails.length () == 1){
                contact.emails = null;
                return;
            }

            contact.emails.remove(contact.emails.nth_data(index));
        }

        public void add_address (Address address){
            if (contact.addresses == null)
                contact.addresses = new List<Address?>();
            contact.addresses.append (address);
        }

        public void remove_address(int index){
            if (contact.addresses.length () == 1){
                contact.addresses = null;
                return;
            }
            contact.addresses.remove(contact.addresses.nth_data(index));
        }

        public void add_note (string note){
            if (contact.notes == null)
                contact.notes = new List<string>();
            contact.notes.append (note);
        }

        public void remove_note(int index){
            if (contact.notes.length () == 1){
                contact.notes = null;
                return;
            }

            contact.notes.remove(contact.notes.nth_data(index));
        }

        public void add_nickname (string nickname){
            if (contact.nicknames == null)
                contact.nicknames = new List<string>();
            contact.nicknames.append (nickname);
        }

        public void remove_nickname(int index){
            if (contact.nicknames.length () == 1){
                contact.nicknames = null;
                return;
            }

            contact.nicknames.remove(contact.nicknames.nth_data(index));
        }

        public void add_website (string webiste){
            if (contact.websites == null)
                contact.websites =  new List<string>();
            contact.websites.append (webiste);
        }

        public void remove_website(int index){
            if (contact.websites.length () == 1){
                contact.websites = null;
                return;
            }

            contact.websites.remove(contact.websites.nth_data(index));
        }
    }

}
