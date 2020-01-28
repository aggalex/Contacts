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
    public class SplitHeaderbar : Gtk.Paned {

        public signal void changed_search (string query);

        private Gtk.HeaderBar mainbox_header = new Gtk.HeaderBar ();
        private Gtk.HeaderBar sidebar_header = new Gtk.HeaderBar ();

        private Gtk.Button add_entry_button = new Gtk.Button.from_icon_name ("contact-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        private Gtk.SearchEntry search = new Gtk.SearchEntry ();
        private Gtk.Button import_button = new Gtk.Button.from_icon_name ("document-import-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        private Gtk.Button export_button = new Gtk.Button.from_icon_name ("document-export-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        public signal void new_contact ();
        public signal void import_vcard ();
        public signal void import_system ();
        public signal void export ();

        public SplitHeaderbar () {
            add_entry_button.set_tooltip_text (_("Create new contact"));
            add_entry_button.clicked.connect (() => {
                new_contact ();
            });

            import_button.set_tooltip_text (_("Import contacts from a file"));
            var import_menu = new SimpleMenu (import_button);
            var vcard_button = import_menu.append ("From vcard file");
            vcard_button.clicked.connect (() => import_vcard ());
            var system_button = import_menu.append ("From system & online accounts");
            system_button.clicked.connect (() => import_system ());

            export_button.set_tooltip_text (_("Export all contacts to a file"));
            export_button.clicked.connect (() => {
                export ();
            });

            search.valign = Gtk.Align.CENTER;
            search.set_placeholder_text (_("Search Contacts"));

            search.changed.connect(() => changed_search (search.get_text()));

            unowned Gtk.StyleContext sidebar_header_context = sidebar_header.get_style_context ();
            sidebar_header_context.add_class ("sidebar-header");
            sidebar_header_context.add_class ("titlebar");
            sidebar_header_context.add_class ("default-decoration");
            sidebar_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            unowned Gtk.StyleContext mainbox_header_context = mainbox_header.get_style_context ();
            mainbox_header_context.add_class ("mainbox-header");
            mainbox_header_context.add_class ("titlebar");
            mainbox_header_context.add_class ("default-decoration");
            mainbox_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            sidebar_header.pack_start (add_entry_button);
            sidebar_header.set_custom_title (search);
            sidebar_header.pack_end (import_button);
            sidebar_header.pack_end (export_button);
            sidebar_header.decoration_layout = "close:";
            sidebar_header.has_subtitle = false;
            sidebar_header.show_close_button = true;

            mainbox_header.has_subtitle = false;
            mainbox_header.decoration_layout = ":maximize";
            mainbox_header.show_close_button = true;

            this.pack1 (sidebar_header, false, false);
            this.pack2 (mainbox_header, true, false);

            unowned Gtk.StyleContext this_context = get_style_context ();
            this_context.add_class ("titlebar-paned");
        }

        public void fix_style () {
            get_style_context ().remove_class ("titlebar");
        }

    }
}

