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
//Based on Granite.SettingsSidebar:
/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

using Granite;
using Granite.Widgets;
using Gtk;

namespace View.Widgets {
    public class Sidebar : Gtk.ScrolledWindow {
        private Gtk.ListBox listbox;
        private bool[] available_headers = new bool[26];

        private uint hidden_counter = 0;

        /**
         * The Gtk.Stack to control
         */
        public Gtk.Stack stack { get; construct; }

        /**
         * The name of the currently visible Granite.SettingsPage
         */
        public string? visible_child_name {
            get {
                var selected_row = listbox.get_selected_row ();

                if (selected_row == null) {
                    return null;
                } else {
                    return ((SidebarRow) selected_row).name;
                }
            }
            set {
                foreach (unowned Gtk.Widget listbox_child in listbox.get_children ()) {
                    if (((SidebarRow) listbox_child).name == value) {
                        listbox.select_row ((Gtk.ListBoxRow) listbox_child);
                    }
                }
            }
        }

        /**
         * Create a new SettingsSidebar
         */
        public Sidebar (Gtk.Stack stack) {
            Object (
                stack: stack
            );
        }

        construct {
            foreach (bool letter in available_headers) {
                letter = false;
            }

            hscrollbar_policy = Gtk.PolicyType.NEVER;
            width_request = 200;
            listbox = new Gtk.ListBox ();
            listbox.activate_on_single_click = true;
            listbox.selection_mode = Gtk.SelectionMode.SINGLE;

            add (listbox);

            on_sidebar_changed ();
            stack.add.connect (on_sidebar_changed);
            stack.remove.connect (on_sidebar_changed);

            listbox.row_selected.connect ((row) => {
                stack.visible_child = ((SidebarRow) row).page;
            });

            listbox.set_header_func ((row, before) => {
                var header = ((SidebarRow) row).header;
                if (header != null && !available_headers[get_index(header.get_char(0))]) {
                    row.set_header (new HeaderLabel (header));
                }
            });
        }

        private int get_index (unichar c) {
            return ((int) c) - 65;
        }

        public void on_sidebar_changed () {
            listbox.get_children ().foreach ((listbox_child) => {
                listbox_child.destroy ();
            });

            var sorted_children = stack.get_children ();
            sorted_children.sort ((a, b) => strcmp (((SettingsPage) a).title, ((SettingsPage) b).title));

            sorted_children.foreach ((child) => {
                if (child is SettingsPage) {
                    var row = new SidebarRow ((SettingsPage) child);
                    listbox.add (row);
                }
            });

            listbox.show_all ();
        }

        public void show_all_rows () {
            listbox.show_all ();
        }

        public void hide_all_rows () {
            foreach (var row in listbox.get_children ()) {
                row.hide ();
            }
        }

        public bool hide_row (uint index) {
            var widget = listbox.get_row_at_index ((int) index);
            if (widget == null) return false;

            return set_visibility (widget, false);
        }

        public bool show_row (uint index) {
            var widget = listbox.get_row_at_index ((int) index);
            if (widget == null) return false;

            return set_visibility (widget, true);
        }

        public bool set_visibility (ListBoxRow widget, bool new_visible) {
            if (widget.visible == new_visible) return false;

            if (hidden_counter == 0 && new_visible = false) listbox.no_show_all = true;
            if (hidden_counter == 1 && new_visible = true) listbox.show_all ();

            widget.visible = new_visible;
            if (new_visible)
                hidden_counter--;
            else
                hidden_counter++;
            return true;
        }
    }
}
