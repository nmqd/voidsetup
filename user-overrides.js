/*** MY OVERRIDES ***/
user_pref("extensions.pocket.enabled", false); // Pocket Account [FF46+]
user_pref("browser.urlbar.suggest.engines", false); // whether to suggest search engines when focusing the address bar
user_pref("browser.urlbar.suggest.openpage", false); // whether to suggest currently open pages when entering text in the address bar
user_pref("browser.urlbar.suggest.topsites", false); // whether to suggest top sites when editing the address bar
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // [FF68+] allow userChrome/userContent
user_pref("layers.acceleration.force-enabled", true); // [FF68+] allow userChrome/userContent
user_pref("gfx.webrender.all", true); // [FF68+] allow userChrome/userContent
user_pref("svg.context-properties.content.enabled", true); // [FF68+] allow userChrome/userContent
user_pref("signon.rememberSignons", false); // Disable saving passwords
