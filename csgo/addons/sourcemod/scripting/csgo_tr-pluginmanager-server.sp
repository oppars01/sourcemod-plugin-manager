#include <sourcemod>
#include <multicolors>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Plugin Manager", 
	author = "oppa", 
	description = "It allows you to manage plugins from the server.", 
	version = "1.0", 
	url = "csgo-turkiye.com"
};

public void OnPluginStart()
{   
    LoadTranslations("csgo_tr-pluginmanager.phrases.txt");
    RegAdminCmd("sm_pluginmanager", PluginList, ADMFLAG_ROOT, "Check the plugins from the server.");
}

public Action PluginList(int client, int args) {
    if(client==0) PrintToServer("%t", "Console Message");
    else PluginListMenu().Display(client,MENU_TIME_FOREVER);
    return Plugin_Handled;
}

Menu PluginListMenu()
{
    char s_plugin_name[128], s_plugin_filename[128], s_plugin_version[32], s_plugin_author[64], s_text[256];
    int i_total = 0;
    Menu menu = new Menu(PluginListMenu_Callback);
    Handle h_plugins_iterator = GetPluginIterator();
    while (MorePlugins(h_plugins_iterator)) {
        Handle h_read_plugin = ReadPlugin(h_plugins_iterator);
        if (!GetPluginInfo(h_read_plugin, PlInfo_Name, s_plugin_name, sizeof(s_plugin_name))) GetPluginFilename(h_read_plugin, s_plugin_name, sizeof(s_plugin_name));
        if (!GetPluginInfo(h_read_plugin, PlInfo_Version, s_plugin_version, sizeof(s_plugin_version))) s_plugin_version[0] = 0;
        if (!GetPluginInfo(h_read_plugin, PlInfo_Author, s_plugin_author, sizeof(s_plugin_author))) Format(s_plugin_author, sizeof(s_plugin_author), "%t", "Anonymous");
        GetPluginFilename(h_read_plugin, s_plugin_filename, sizeof(s_plugin_filename)); 
        Format(s_text, sizeof(s_text), "%t", "Plugin List Item", s_plugin_name, s_plugin_filename, s_plugin_version, s_plugin_author);
        menu.AddItem(s_plugin_filename, s_text);
        delete h_read_plugin;
        i_total++;
    }
    delete h_plugins_iterator;
    Format(s_text, sizeof(s_text), "%t", "Plugin List Title", i_total);
    menu.SetTitle(s_text);
    return menu;
}

int PluginListMenu_Callback(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
        char s_plugin_filename[32];
        menu.GetItem(param2, s_plugin_filename, sizeof(s_plugin_filename));
        PluginSettingMenu(s_plugin_filename).Display(client,MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_End) delete menu;
}

Menu PluginSettingMenu(char[] plugin_filename)
{
    char s_text[256],s_text2[64];
    Menu menu = new Menu(PluginSettingMenu_Callback);
    Format(s_text, sizeof(s_text), "%t", "Plugin Setting Title", plugin_filename);
    menu.SetTitle(s_text);
    Format(s_text, sizeof(s_text), "sm plugins reload %s", plugin_filename);
    Format(s_text2, sizeof(s_text2), "%t", "Plugin Setting Reload");
    menu.AddItem(s_text, s_text2);
    Format(s_text, sizeof(s_text), "sm plugins load %s", plugin_filename);
    Format(s_text2, sizeof(s_text2), "%t", "Plugin Setting Load");
    menu.AddItem(s_text, s_text2);
    Format(s_text, sizeof(s_text), "sm plugins unload %s", plugin_filename);
    Format(s_text2, sizeof(s_text2), "%t", "Plugin Setting Unload");
    menu.AddItem(s_text, s_text2);
    return menu;
}

int PluginSettingMenu_Callback(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
        char s_command[256];
        menu.GetItem(param2, s_command, sizeof(s_command));
        ServerCommand(s_command);
        CPrintToChat(client,"%t", "Plugin Setting Callback", s_command);
        PluginListMenu().Display(client,MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_End) delete menu;
}

