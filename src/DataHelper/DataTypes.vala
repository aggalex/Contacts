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

namespace DataHelper {

    public enum Type {

        HOME, WORK, OTHER, WEBSITE, NICKNAME, BIRTHDAY, ANNIVERSARY, NOTES;

        public const Type[] MISC = { Type.WEBSITE,  Type.NICKNAME,  Type.BIRTHDAY, Type.ANNIVERSARY, Type.NOTES};

        public const Type[] ALL = { Type.HOME,  Type.WORK,  Type.OTHER};

        public const Type DEFAULT = HOME;

        public const Type MISC_DEFAULT = NOTES;

        public string to_string () {
            switch (this) {
                case HOME: return "Home";
                case WORK: return "Work";
                case OTHER: return "Other";
                case WEBSITE: return "Website";
                case NICKNAME: return "Nickname";
                case BIRTHDAY: return "Birthday";
                case ANNIVERSARY: return "Anniversary";
                case NOTES: return "Notes";
                default: return DEFAULT.to_string ();
            }
        }

        public string to_string_translated () {
            switch (this) {
                case HOME: return _("Home");
                case WORK: return _("Work");
                case OTHER: return _("Other");
                case WEBSITE: return _("Website");
                case NICKNAME: return _("Nickname");
                case BIRTHDAY: return _("Birthday");
                case ANNIVERSARY: return _("Anniversary");
                case NOTES: return _("Notes");
                default: return DEFAULT.to_string_translated ();
            }
        }

        public static Type parse (string str) {
            switch (str) {
                case "Home": return HOME;
                case "Work": return WORK;
                case "Other": return OTHER;
                case "Website": return WEBSITE;
                case "Nickname": return NICKNAME;
                case "Birthday": return BIRTHDAY;
                case "Anniversary": return ANNIVERSARY;
                case "Notes": return NOTES;
                default: return DEFAULT;
            }
        }

        public static Type parse_int (int i) {
            print (@"INSIDE PARSE_INT: $i\n");
            switch (i) {
                case 0: return HOME;
                case 1: return WORK;
                case 2: return OTHER;
                case 3: return WEBSITE;
                case 4: return NICKNAME;
                case 5: return BIRTHDAY;
                case 6: return ANNIVERSARY;
                case 7: return NOTES;
                default: return DEFAULT;
            }
        }
    }

    public class DataWithType<G> {
        public G data;
        public Type type;

        public DataWithType (G data, Type type) {
            this.data = data;
            this.type = type;
        }
    }
}
