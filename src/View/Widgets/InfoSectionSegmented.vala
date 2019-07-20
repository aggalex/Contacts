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

using DataHelper;

namespace View.Widgets {

    public class HandlerInterfaceSegmented {
        public delegate void HandlerAddFunc (Address data, DataHelper.Type type);
        public delegate void HandlerRemoveFunc (int index);
        public delegate bool HandlerSetFunc (Address data, DataHelper.Type type, int index);

        public HandlerAddFunc add;
        public HandlerRemoveFunc remove;
        public HandlerSetFunc change;
    }

    public class InfoSectionSegmented : InfoSection{

        internal new HandlerInterfaceSegmented handler = new HandlerInterfaceSegmented ();

        private string[] format_strings;
        private string[] placeholders;

        public InfoSectionSegmented (string title, string[] placeholders, string[] format_strings) {
            base (title);
            this.placeholders = placeholders;
            this.format_strings = format_strings;
        }

        protected override void add_button_action () {
            new_entry (null, DataHelper.Type.DEFAULT);
        }

        public new void new_entry (string[]? data, DataHelper.Type type) {
            EditableLabelSegmented entry;
            if (data == null || data.length != placeholders.length)
                entry = new EditableLabelSegmented.empty (placeholders, type);
            else
                entry = new EditableLabelSegmented (data, placeholders, type);
            entry.format (format_strings);
            _new_entry (entry);
        }

        protected override void handler_new_entry (EditableWidget widget) {
            var label = (EditableLabelSegmented) widget;
            var address = extract_address_data (label.text_array);
            handler.add (address, widget.data_type);
        }

        public override void handler_change_entry (EditableWidget widget, int index) {
            var label = (EditableLabelSegmented) widget;
            var address = extract_address_data (label.text_array);
            handler.change (address, widget.data_type, index);
        }

        protected override void handler_remove_entry (int index, DataHelper.Type? type) {
            handler.remove (index);
        }

        private static Address extract_address_data (List<string> data) {
            return Address () {
                street = data.nth_data (0),
                city = data.nth_data (1),
                state = data.nth_data (2),
                zip = data.nth_data (3),
                country = data.nth_data (4)
            };
        }
    }
}
