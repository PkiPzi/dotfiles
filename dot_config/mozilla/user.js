// Memory-lean Firefox. Linked into every *.default-release profile by run_onchange_after_40-firefox.sh.
// Applied on the next Firefox start.
user_pref("browser.sessionhistory.max_total_viewers", 2);   // back/forward cache pages kept alive (auto = up to 8 on 16 GB)
user_pref("browser.cache.memory.capacity", 65536);          // KB of RAM page cache (auto picks more)
user_pref("dom.ipc.processPrelaunch.enabled", false);       // no idle spare content process
user_pref("dom.ipc.keepProcessesAlive.web", 0);             // don't keep an empty content process after closing a tab
user_pref("dom.ipc.processCount", 4);                       // shared web process pool (default 8)
user_pref("browser.tabs.unloadOnLowMemory", true);          // let Firefox discard background tabs under memory pressure
user_pref("browser.sessionstore.max_tabs_undo", 5);
user_pref("browser.sessionstore.interval", 60000);          // less disk churn than the 15 s default

// Less background work: sponsored/Pocket new-tab feeds, suggestions, telemetry and studies
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.system.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("extensions.pocket.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.trending", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
