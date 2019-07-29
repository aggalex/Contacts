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
using Gtk;

using ViewModel;

namespace View.Widgets {

    public class HandlerInterface {
        public delegate void HandlerAddFunc (string data, DataHelper.Type type);
        public delegate void HandlerRemoveFunc (int index);
        public delegate bool HandlerSetFunc (string data, DataHelper.Type type, int index);

        public HandlerAddFunc add;
        public HandlerRemoveFunc remove;
        public HandlerSetFunc change;
    }

    public class InfoSection : Gtk.Box {

        public signal void opened_entry ();

        protected string title;
        protected Gtk.Label title_label = new Gtk.Label (null);

        private ListBox list_box = new Gtk.ListBox ();
        private int population = 0;
        public bool can_write = false;

        internal HandlerInterface handler = new HandlerInterface ();

        protected Gtk.Button add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);

        public InfoSection (string title) {
            this.title = title;
            title_label.set_text (title);
        }

        construct {
            add_button.clicked.connect (add_button_action);

            this.set_orientation (Gtk.Orientation.VERTICAL);
            this.set_spacing (0);

            title_label.xalign = 0;
            title_label.margin = 6;
            var title_label_context = title_label.get_style_context ();
            title_label_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            title_label_context.add_class ("bold");

            add_button.margin = 6;
            add_button.set_tooltip_text (_("Add a new empty entry"));

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (add_button, false, false, 0);
            label_box.pack_start (title_label, false, false, 0);

            this.pack_start (label_box, false, false, 0);
            this.pack_start (list_box, false, false, 0);
            this.get_style_context ().add_class ("transparent_background");
            this.margin = 12;
            this.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }

        protected virtual void add_button_action () {
            new_entry ("", DataHelper.Type.DEFAULT);
        }

        public void new_entry (string data, DataHelper.Type type) {
            var entry = new EditableLabel (data, type);
            _new_entry (entry);
        }

        protected void _new_entry (EditableWidget entry, int? index = null) {
            string data = entry.text;

            if (can_write) handler_new_entry (entry);

            if (index == null) 
                index = population++;
            else
                population++;

            entry.changed.connect (() => {
                if (can_write)
                    handler_change_entry (entry, index);
            });

            var entry_revealer = new Gtk.Revealer ();
            entry_revealer.set_transition_type (RevealerTransitionType.SLIDE_DOWN);
            entry_revealer.add (entry);
            entry_revealer.set_reveal_child (false);

            var row = new Gtk.ListBoxRow ();
            row.set_selectable (false);
            row.set_name (data + "_row");
            row.add (entry_revealer);

            entry.deleted.connect (() => {
                entry_revealer.reveal_child = false;
                remove_entry_wrapper ((ListBoxRow) entry_revealer.get_parent (), entry.data_type, index);
            });

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            list_box.add (separator);
            list_box.add (row);
            list_box.show_all ();

            entry_revealer.set_reveal_child (true);
        }

        protected ListIterator<Widget> iterator () {
            return new ListIterator<Widget> (list_box.get_children ());
        }

        protected virtual void handler_new_entry (EditableWidget widget) {
            handler.add (widget.text, widget.data_type);
        }

        protected virtual void handler_change_entry (EditableWidget widget, int index) {
            handler.change (widget.text, widget.data_type, index);
        }

        private void remove_entry_wrapper (Gtk.ListBoxRow sender, DataHelper.Type? type, int index) {
            list_box.remove (list_box.get_row_at_index (sender.get_index () - 1));
            list_box.remove (sender);
            if (can_write) handler_remove_entry (index, type);
            population--;
        }

        protected virtual void handler_remove_entry (int index, DataHelper.Type? type) {
            handler.remove (index);
        }
    }

    public class ListIterator<G> {
        public int i = 0;
        public unowned List<G> list;

        public ListIterator (List<G> list) {
            this.list = list;
        }

        public ListIterator<G> iterator () {
            return this;
        }

        public G @get () {
            return list.nth_data (i++);
        }

        public bool next () {
            return list.length () > i;
        }
    }
}
