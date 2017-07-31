<!--- Main plugin page. All requests are being handled here. --->

<cfscript>
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

