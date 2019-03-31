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

namespace Contacts {

    public class DataTypes {

        public const string HOME = "Home";
        public const string WORK = "Work";
        public const string OTHER = "Other";

        public class MISC {

            public const string WEBSITE = "Website";
            public const string NICKNAME = "Nickname";
            public const string BIRTHDAY = "Birthday";
            public const string NOTES = "Notes";

            public const string DEFAULT = NOTES;

            public const string[] ALL = {WEBSITE, NICKNAME, BIRTHDAY, NOTES};

        }

        public const string DEFAULT = HOME;

        public const string[] ALL = {HOME, WORK, OTHER};

    }
}
