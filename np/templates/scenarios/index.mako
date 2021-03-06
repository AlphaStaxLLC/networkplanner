<%inherit file="/base.mako"/>\
\
<%def name="title()">Scenario Index</%def>\
\
<%def name="css()">
.scenarioOFF {color: black; background-color: white} 
.scenarioON {color: black; background-color: yellow}
.alignL {text-align: left}
</%def>\
\
<%def name="head()">
${h.stylesheet_link('/files/dataTables/css/dataTablesNP.css')}
${h.javascript_link('/files/dataTables/dataTablesPlus.min.js')}
</%def>\
\
<%def name="js()">
var scenariosDataTable;
function applyDataTable() {
    var aaSorting;
    if (scenariosDataTable) {
        scenariosDataTable.fnClearTable(false);
        aaSorting = scenariosDataTable.fnSettings().aaSorting;
    } else {
        aaSorting = [[ 2, 'desc' ]];
    }
    scenariosDataTable = $('#scenarios').dataTable({
        'bDestroy': true,
        'bPaginate': false,
        'bAutoWidth': true,
        'oLanguage': {
            'sSearch': 'Filter'
        },
        'aaSorting': aaSorting,
        'aoColumns': [
            {'sType': 'string'},
            {'sType': 'string'},
            {'sType': 'title-string'},
            {'sType': 'string'},
            {'sType': 'string'},
            {'bSortable': false}
        ]
    });
    $('#scenarios_filter input').focus();
}
$('#feedback').click(function() {
    var text = prompt('Please enter your comments below.');
    if (text) {
        $.post("${h.url('scenario_feedback')}", {text: text}, function(data) {
            if (data.isOk) {
                $('#message').html('Thanks!').fadeOut(3000, function () {$(this).html('').show()});
            } else if (data.message) {
                alert(data.message);
            }
        });
    }
});
$('#create').click(function() {
    if (${h.isPerson()}) {
        window.location = "${h.url('new_scenario')}";
    } else {
        window.location = "${h.url('person_login', targetURL=h.encodeURL(h.url('new_scenario')))}";
    }
});
$('.delete').click(function() {
    if(confirm('Are you sure you want to delete scenario ID ' + getID(this) + '?')) {
        var scenarioID = getID(this);
        $('#scenario' + scenarioID).hide();
        $.ajax({
            type: 'DELETE',
            url: "${h.url('scenario', id='XXX')}".replace('XXX', scenarioID),
            success: function(data) {
                if (!data.isOk) {
                    $('#scenario' + scenarioID).show();
                    alert(data.message);
                }
            },
            dataType: 'json'});
    }
});
$('.scenario').hover(
    function() {
        var scenarioID = getID(this);
        var scenarioName = $('#scenarioName' + scenarioID)[0];
        scenarioName.className = scenarioName.className.replace('OFF', 'ON');
    }, 
    function() {
        var scenarioID = getID(this);
        var scenarioName = $('#scenarioName' + scenarioID)[0];
        scenarioName.className = scenarioName.className.replace('ON', 'OFF');
    }
);
$('#scope').change(function() {
    $.get("${h.url('scenario_index')}", {
        scope: this.value,
        refresh: 1
    }, function(data) {
        $('#scenariosBody').html(data);
        applyDataTable();
        $('#scenariosBody a').hover(
            function () {this.className = this.className.replace('OFF', 'ON');}, 
            function () {this.className = this.className.replace('ON', 'OFF');}
        );
    });
});
applyDataTable();
</%def>\
\
<%def name="toolbar()">
<%
from np import model 
personID = h.getPersonID()
%>
<input type=button id=create value="Create new scenario" title="Run a scenario using your own datasets and parameters">
<!-- <input type=button id=feedback value="Send feedback" title="Send comments or bug reports"> -->
% if personID:
<select id=scope>
    <option value=${model.scopePrivate}>Private</option>
    <option value='-'>Mine</option>
    <option value='*'>All</option>
</select>
% endif
<span id=message></span>
</%def>
\
% if c.scenarios:
<table class=maximumWidth id=scenarios>
<thead class=scenarios>
<tr>
    <th class="alignL scenarios"><b>Owner</b></th>
    <th class="alignL scenarios"><b>Name</b></th>
    <th class="alignL scenarios"><b>Created</b></th>
    <th class="alignL scenarios"><b>Status</b></th>
    <th class="alignL scenarios"><b>Scope</b></th>
</tr>
</thead>
<tbody class=scenarios>
<%include file='scenarios.mako'/>\
</tbody>
</table>
% endif
