# Dalamud plugin repository

This repository hosts plugin binaries that are used with [Dalamud](https://github.com/goatcorp/Dalamud), which is managed by [FFXIVQuickLauncher](https://github.com/goaaats/FFXIVQuickLauncher).

They are made and maintained by third party developers. Plugins being on here doesn't mean that we endorse them, it just means that they follow our rules/standards for submissions.

## Installing Plugins

To install plugins, you'll need to use XIVLauncher with the in-game addon (Dalamud) enabled. Once Dalamud has loaded, you can type `/xlplugins` in game to open a plugin installed.

You do not need to download any of the plugins here manually. Plugin installation is handled inside of the game directly.

## Making a plugin

Please see the [API documentation](https://goatcorp.github.io/Dalamud/api/index.html) for information about creating plugins.

### What should my plugin not do?
Make sure that your plugin does not directly interact with the game servers in a way that is:
<br>a) *automatic*, as in polling data or making requests without direct interaction from the user.
<br>b) *outside of specification*, as in allowing the player to do submit things to the server that would not be possible by normal means.

## Publishing/updating your plugin

Create a pull request with your own subfolder in the plugins directory of this folder. It should be named the "internal" name(name of the DLL) of your plugin and contain a [plugin definition file](https://github.com/goatcorp/DalamudPlugins/blob/master/plugins/owofy/owofy.json) with the same name.
It should also contain a zip called "latest.zip" containing your plugin DLL, dependencies, resources and the plugin definition json in the same folder as the plugin DLL.

When the AssemblyVersion of the locally installed plugin doesn't match the "AssemblyVersion" field of the plugin definition json pushed to this repository, a redownload of the plugin is forced.

For a sample of this, please see my [sample plugin](https://github.com/goatcorp/DalamudPlugins/blob/master/plugins/owofy).

### Plugin testing

When releasing a new plugin or making bigger changes, please PR your plugin inside the ``testing`` folder on this repository first - this lets users that opt into receiving testing releases see the plugin in their installer. You can join our [Discord server](https://discord.gg/3NMcUV5) to make an announcement in our testers channel.

This should usually not take more than a week - but it helps weeding out bigger issues that could cause crashes or prevent the plugin from being updated.

---

When submitting a plugin, please consider our [Acceptable Use Policy](https://github.com/goatcorp/FFXIVQuickLauncher/wiki/Acceptable-Use-Policy-(Official-Plugin-Repository)) & [Terms of Service](https://github.com/goatcorp/FFXIVQuickLauncher/wiki/Terms-and-Conditions-of-Use-(XIVLauncher,-Dalamud-&-Official-Plugin-Repository)), which, for example, detail the rights you need to grant us when uploading a plugin to this repository.
