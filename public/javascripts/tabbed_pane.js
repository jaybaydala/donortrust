function tabselect(tab) {
  var tablist = $('tabcontrol1').getElementsByTagName('li');
  var nodes = $A(tablist);
  var lClassType = tab.className.substring(0, tab.className.indexOf('-') );

  nodes.each(function(node){
    if (node.id == tab.id) {
      tab.className=lClassType+'-selected';
    } else {
      node.className=lClassType+'-unselected';
    };
  });
}

function paneselect(pane) {
  var panelist = $('panecontrol1').getElementsByTagName('li');
  var nodes = $A(panelist);

  nodes.each(function(node){
    if (node.id == pane.id) {
      pane.className='pane-selected';
    } else {
      node.className='pane-unselected';
    };
  });
}

function loadPane(pane, src) {
  if (pane.innerHTML=='' || pane.innerHTML=='<img alt="Wait" src="/images/spinner.gif" style="vertical-align:-3px" /> Loading...') {
    reloadPane(pane, src);
  }
}

function reloadPane(pane, src) {
  new Ajax.Updater(pane, src, {asynchronous:1, evalScripts:true, onLoading:function(request){pane.innerHTML='<img alt="Wait" src="/images/spinner.gif" style="vertical-align:-3px" /> Loading...'}})
}