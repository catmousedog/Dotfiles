// ConfigService.qml
pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick
import QtCore
import qs.config

Singleton {
    id: root
    property var state: ({})
    Component.onCompleted: root.loadState()

    FileView {
        id: defaultConfig
        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/config/defaults.json"
        watchChanges: false
        blockLoading: true
    }

    FileView {
        id: localConfig
        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/local/config.json"
        watchChanges: false
        blockLoading: true
    }

    function loadState() {
        let defaults = {};
        let userConfig = {};

        try {
            defaults = JSON.parse(defaultConfig.text());
        } catch (e) {
            console.error("[ConfigService] Failed to parse default config:", e);
        }

        try {
            userConfig = JSON.parse(localConfig.text());
        } catch (e) {
            console.warn("[ConfigService] Failed to parse local config:", e);
        }

        root.state = root.deepMerge(defaults, userConfig);
    }

    // Merges 'override' into 'base' recursively, returning a new object
    function deepMerge(base, override) {
        const result = Object.assign({}, base);
        for (const key of Object.keys(override)) {
            if (typeof override[key] === 'object' && override[key] !== null && !Array.isArray(override[key]) && typeof base[key] === 'object' && base[key] !== null && !Array.isArray(base[key])) {
                result[key] = root.deepMerge(base[key], override[key]);
            } else {
                result[key] = override[key];
            }
        }
        return result;
    }

    function get(jsonkey) {
        const keys = jsonkey.split('.');
        let current = root.state;
        for (const key of keys) {
            if (current !== null && typeof current === 'object' && key in current) {
                current = current[key];
            } else {
                console.warn("[ConfigService] Key not found:", jsonkey);
                return undefined;
            }
        }
        return current;
    }

    function getColor(jsonkey) {
        return Theme.getColor(get(jsonkey));
    }
}
