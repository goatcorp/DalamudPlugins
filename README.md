# Dalamud plugin repository

This repository hosts plugin binaries and update definitions for [FFXIVQuickLauncher](https://github.com/goaaats/FFXIVQuickLauncher).

## Making a plugin

Please see the [API documentation](https://goatcorp.github.io/Dalamud/api/index.html) for information about creating plugins.

### What should my plugin not do?
Make sure that your plugin does not directly interact with the game servers in a way that is:
<br>a) *automatic*, as in polling data or making requests without direct interaction from the user.
<br>b) *outside of specification*, as in allowing the player to do submit things to the server that would not be possible by normal means.

## Publishing/updating your plugin

Create a pull request with your own subfolder in the plugins directory of this folder. It should be named the "internal" name(name of the DLL) of your plugin and contain a [plugin definition file](https://github.com/goatcorp/DalamudPlugins/blob/master/plugins/owofy/owofy.json) with the same name.
It should also contain a zip called "latest.zip" containing your plugin DLL, dependencies, resources and the plugin definition json ins the same folder as the plugin DLL.

When the AssemblyVersion of the locally installed plugin doesn't match the "AssemblyVersion" field of the plugin definition json pushed to this repository, a redownload of the plugin is forced.

For a sample of this, please see my [sample plugin](https://github.com/goatcorp/DalamudPlugins/blob/master/plugins/owofy).
