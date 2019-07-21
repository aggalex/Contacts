/*
* Copyright (c) {{yearrange}} Alex Angelou ()
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
using Granite;
using Granite.Widgets;
using Gtk;

using View;
using ViewModel;

namespace Contacts {
    public class Application : Granite.Application {

        public Application () {
            Object(
                application_id: "com.github.aggalex.Contacts", 
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate () {
            var window = new Gtk.ApplicationWindow (this);

            var contact_list = new ContactList ();
            window.add (contact_list);

            var headerbar = new Headerbar ();
            window.set_titlebar (headerbar);
            headerbar.changed_search.connect ((query) => contact_list.search (query));
            headerbar.new_contact.connect (() => contact_list.add_empty_contact ());

            Css.apply ();
            window.title = _("Contacts");
            window.set_default_size (900, 640);
            window.show_all ();

            contact_list.initialize ();
        }

        public static int main (string[] args) {
            var app = new Contacts.Application ();
            return app.run (args);
        }
    }
}
