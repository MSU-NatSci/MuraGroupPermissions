
component accessors=true extends='mura.plugin.pluginGenericEventHandler' output=false {

    include 'plugin/settings.cfm';

    public any function onApplicationLoad(required struct m) {
        variables.pluginConfig.addEventHandler(this);
    }

}
