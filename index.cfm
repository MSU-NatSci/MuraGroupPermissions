<!--- Main plugin page. All requests are being handled here. --->

<cfscript>
    include 'plugin/config.cfm';
    import model.websites;
    import model.contacts;

    action($, pluginConfig);

    function action($, pluginConfig) {
        var action = $.event('action');

        if (action == 'permissions')
            include 'views/groupPermissions.cfm';
        else
            include 'views/groupList.cfm';
    }
</cfscript>
