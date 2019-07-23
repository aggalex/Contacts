# project name and programming language
project('com.github.aggalex.contacts', 'vala', 'c', version: '0.1.0')

message ('project name and programming language')

# Adds project arguments
message ('Adds project arguments')

add_project_arguments([
        '-DGETTEXT_PACKAGE=\"@0@\"'.format(meson.project_name())
    ],
    language: 'c',
)

# Include the translations module
message('Include the translations module')

i18n = import('i18n')

# Set our translation domain
message ('Set our translation domain')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Adding deps
message ('Listing dependencies')

dependencies = [
    dependency('gio-unix-2.0', version: '>=2.20'),
    dependency('granite'),
    dependency('json-glib-1.0'),
    dependency('folks'),
]

# Adds subfolders specific build system
message ('Adds subfolders specific build system')

icon_sizes = ['16','24','32','48', '64', '128', '256']

foreach i : icon_sizes
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

avatar_sizes = ['32', '64']

foreach i : avatar_sizes
    install_data(
        join_paths('data/icons', i, 'contacts-avatar-default.svg'),
        install_dir: join_paths(get_option('datadir'), 'contacts', 'avatars', i)
    )
endforeach

install_data(
    'data/css/style.css',
    install_dir: join_paths(get_option('datadir'), 'contacts', 'css')
)

config_data = configuration_data()
config_data.set('EXEC_NAME', meson.project_name())

# Src build
message ('Src build')

conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))

message ('Configuring desktop entry: ' + meson.project_name() + '.desktop')

desktop_in_file = configure_file(
    input: join_paths('data', meson.project_name() + '.desktop.in.in'),
    output: '@BASENAME@',
    configuration: config_data
)

config_file = configure_file(
    input: 'config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

desktop_file = i18n.merge_file(
    input: desktop_in_file,
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

appstream_file = i18n.merge_file(
    input: join_paths (meson.source_root(), 'data', meson.project_name() + '.appdata.xml.in'),
    output: '@BASENAME@',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

message ('Installing desktop entry: ' + meson.project_name() + '.desktop')

install_data(
    desktop_in_file,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

message ('Adds files to build')

subdir('po')

code_files = files(
    join_paths ('build', '@0@'.format(config_file)),

    'src/DataHelper/DataTypes.vala',
    'src/DataHelper/Address.vala',

    'src/FileHelper/FileHelper.vala',

    'src/FolksHelper/FolksLoader.vala',

    'src/JsonHelper/JsonParser.vala',
    'src/JsonHelper/JsonBuilder.vala',

    'src/QuotedPrintableHelper/QuotedPrintableParser.vala',

    'src/VCardHelper/VCardBuilder.vala',
    'src/VCardHelper/VCardParser.vala',

    'src/Model/ContactList.vala',
    'src/Model/Contact.vala',

    'src/ViewModel/ContactListHandler.vala',
    'src/ViewModel/ContactHandler.vala',

    'src/View/ContactList.vala',
    'src/View/Headerbar.vala',
    'src/View/Contact.vala',
    'src/View/Css.vala',

    'src/View/Widgets/InfoSectionMisc.vala',
    'src/View/Widgets/LightStack.vala',
    'src/View/Widgets/EditableWidget.vala',
    'src/View/Widgets/Popover.vala',
    'src/View/Widgets/EditableLabelDate.vala',
    'src/View/Widgets/SidebarRow.vala',
    'src/View/Widgets/EditableTitle.vala',
    'src/View/Widgets/ErrorBar.vala',
    'src/View/Widgets/EditableLabel.vala',
    'src/View/Widgets/SimpleMenu.vala',
    'src/View/Widgets/EditableLabelNoType.vala',
    'src/View/Widgets/InfoSectionSegmented.vala',
    'src/View/Widgets/InfoSection.vala',
    'src/View/Widgets/Sidebar.vala',
    'src/View/Widgets/EditableLabelSegmented.vala',
    'src/View/Widgets/IconPopup.vala',

    'src/Application.vala'
)

message ('Defines executable')

executable(
    meson.project_name(),
    code_files,
    dependencies: dependencies,
    install: true
)
