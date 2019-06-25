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
using Granite;
using Granite.Widgets;

using View.Widgets;

namespace View {
    public class Headerbar : Gtk.HeaderBar {

        public signal void changed_search (string query);

        private Gtk.Button add_entry_button = new Gtk.Button.from_icon_name ("contact-new", Gtk.IconSize.LARGE_TOOLBAR);
        private Gtk.SearchEntry Search = new Gtk.SearchEntry ();
        private Gtk.Button export_button = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
        private Gtk.Button import_button = new Gtk.Button.from_icon_name ("document-import", Gtk.IconSize.LARGE_TOOLBAR);

        public signal void new_contact (string name);
        public signal void import ();
        public signal void export ();

        public Headerbar () {
            add_entry_button.set_tooltip_text ("Create new contact");

            var popover = new Popover (add_entry_button);

            add_entry_button.clicked.connect (() => {
                popover.popup ();
                popover.show_all ();
            });

            popover.activated.connect (() => {
                new_contact (popover.text);
            });

            Search.valign = Gtk.Align.CENTER;
            Search.set_placeholder_text ("Search Contacts");

            Search.changed.connect(() => changed_search (Search.get_text()));

            import_button.clicked.connect (() => import ());

            this.pack_start (add_entry_button);
            this.pack_start (Search);
            this.pack_end (export_button);
            this.pack_end (import_button);
            this.set_show_close_button (true);
        }
    }
}
