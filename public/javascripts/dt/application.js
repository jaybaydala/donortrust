Event.observe(window, 'load', function() {
	if (anchors = $$('a')) {
		anchors.each(function(anchor) {
			if (anchor.getAttribute("href") && anchor.getAttribute("rel") == "blank" && !anchor.getAttribute("target"))
				anchor.target = "_blank"
		});
	}
	ua=navigator.userAgent.toLowerCase();
	ie = document.all && ua.search(/msie/i) != -1 ? true : false;
	old_ie = ie && ua.search(/msie [0-6]/i) != -1 ? true : false;
	if (!old_ie) {
		if (submits = $$('input.buttonsubmit')) {
			i = 0;
			submits.each(function(s) {
				button = new SubmitButton(s, i)
				i++;
			});
		}
	}
	if (notices = $$('div.notice')) {
		notices.each(function(s) {
			new Effect.Highlight(s,{delay:2,duration:1,startcolor:'#FFFFDD',endcolor:'#FFFFFF',restorecolor:'#FFFFFF'})
		});
	}
	if (giftform = $('giftform')) {
	  if ($('gift_send_email_now').checked || $('gift_send_email_false').checked) {
	    $('gift_send_at').hide();
	  } else {
	    $('gift_send_at').show();
	  }
	}
});

Ajax.Responders.register({
	onCreate: function() {
		if($('ajax_busy') && Ajax.activeRequestCount > 0){
			Effect.Appear('ajax_busy', {durations: 0.5, queue: 'end'});
		}
	},
	onComplete: function(){
		if($('ajax_busy') && Ajax.activeRequestCount == 0){
			Effect.Fade('ajax_busy', {duration: 0.5, queue: 'end'});
		}
	}
});


var SubmitButton = Class.create();
SubmitButton.prototype = {
	button: null,
	parent: null,
	form: null,
	value: null,
	size: null,
	id: null,
	name: 'buttonsubmit',
	initialize: function(button, id) {
		this.button = button
		this.id = id
		this.parent = button.up();
		this.form = button.up('form');
		this.value = $F(button);
		this.size = this.getSize();
		this.createLinkNode();
		Element.hide(button);
	},
	getSize: function() {
		if (!this.size) {
			len = this.value.length;
			if (len <= 8) {
				this.size = 'small'
			} else if(len <= 14) {
				this.size = 'medium'
			} else {
				this.size = 'large';
			}
		}
		return this.size;
	},
	createLinkNode: function() {
		div = document.createElement('div')
		div.id = this.name + '-' + this.id;
		div.className = this.name;
		this.parent.insertBefore(div, this.button)
		div = $(this.name + '-' + this.id)
		a = document.createElement('a');
		a.id = this.name + 'link-' + this.id;
		a.href = 'javascript:void(0);';
		a.className = this.size;
		a.innerHTML = this.value;
		div.appendChild(a);
		this.linkObserver()
	},
	linkObserver: function() {
		a = $(this.name + 'link-' + this.id);
		if (this.button.onclick && this.button.onclick.value != '')
			Event.observe(a, 'click', this.button.onclick)
		else
			Event.observe(a, 'click', this.submitForm.bindAsEventListener(this))
	},
	submitForm: function(e) {
		this.form.submit();
	}
}

/* ADVANCED SEARCH */
function assign_selected(elem, label){
	obj = label+'_selected';
	if (label=='funding_req'){
		if($('funding_req_max').value=='' && $('funding_req_min').value==''){
			$(obj).value     = '0';
			$(obj).checked   = false;
			$(obj).innerHTML = obj;
		}else{
			$(obj).value     = '1';
			$(obj).checked   = true;
			$(obj).innerHTML = $('obj');
		}
	}else{
		if (elem.value==0){
			$(obj).value     = '0';
			$(obj).checked   = false;
			$(obj).innerHTML = $('obj');
		} else {
			$(obj).value     = '1';
			$(obj).checked   = true;
			$(obj).innerHTML = $('obj');
		}
	}
}

/* project accordion */
var Accordion = Class.create({

    initialize: function(id, defaultExpandedCount) {
        if(!$(id)) throw("Attempted to initalize accordion with id: "+ id + " which was not found.");
        this.accordion = $(id);
        this.options = {
            toggleClass: "accordion-toggle",
            toggleActive: "accordion-toggle-active",
            contentClass: "accordion-content"
        }
        this.contents = this.accordion.select('div.'+this.options.contentClass);
        this.isAnimating = false;
        this.maxHeight = 0;
        this.current = defaultExpandedCount ? this.contents[defaultExpandedCount-1] : this.contents[0];
        this.toExpand = null;

        this.checkMaxHeight();
        this.initialHide();
        this.attachInitialMaxHeight();

        var clickHandler =  this.clickHandler.bindAsEventListener(this);
        this.accordion.observe('click', clickHandler);
    },

    expand: function(el) {
        this.toExpand = el.next('div.'+this.options.contentClass);
        if(this.current != this.toExpand){
			this.toExpand.show();
            this.animate();
        }
    },

    checkMaxHeight: function() {
        for(var i=0; i<this.contents.length; i++) {
            if(this.contents[i].getHeight() > this.maxHeight) {
                this.maxHeight = this.contents[i].getHeight();
            }
        }
    },

    attachInitialMaxHeight: function() {
		this.current.previous('div.'+this.options.toggleClass).addClassName(this.options.toggleActive);
        if(this.current.getHeight() != this.maxHeight) this.current.setStyle({height: this.maxHeight+"px"});
    },

    clickHandler: function(e) {
        var el = e.element();
        if(el.hasClassName(this.options.toggleClass) && !this.isAnimating) {
            this.expand(el);
        }
    },

    initialHide: function(){
        for(var i=0; i<this.contents.length; i++){
            if(this.contents[i] != this.current) {
                this.contents[i].hide();
                this.contents[i].setStyle({height: 0});
            }
        }
    },

    animate: function() {
        var effects = new Array();
        var options = {
            sync: true,
            scaleFrom: 0,
            scaleContent: false,
            transition: Effect.Transitions.sinoidal,
            scaleMode: {
                originalHeight: this.maxHeight,
                originalWidth: this.accordion.getWidth()
            },
            scaleX: false,
            scaleY: true
        };

        effects.push(new Effect.Scale(this.toExpand, 100, options));

        options = {
            sync: true,
            scaleContent: false,
            transition: Effect.Transitions.sinoidal,
            scaleX: false,
            scaleY: true
        };

        effects.push(new Effect.Scale(this.current, 0, options));

        var myDuration = 0.75;

        new Effect.Parallel(effects, {
            duration: myDuration,
            fps: 35,
            queue: {
                position: 'end',
                scope: 'accordion'
            },
            beforeStart: function() {
                this.isAnimating = true;
                this.current.previous('div.'+this.options.toggleClass).removeClassName(this.options.toggleActive);
                this.toExpand.previous('div.'+this.options.toggleClass).addClassName(this.options.toggleActive);
            }.bind(this),
            afterFinish: function() {
                this.current.hide();
                this.toExpand.setStyle({ height: this.maxHeight+"px" });
                this.current = this.toExpand;
                this.isAnimating = false;
            }.bind(this)
        });
    }

});


/* end accordion */

/* Project view | activates a tab and show its content*/
function tab_select(item, section){
  
   $('project_plan').hide();
   $('intended_outcome').hide();
   $('measurable_feedback').hide();
   $('project_photos').hide();
   $('project_videos').hide();
   
   if( $('project-li')){
     $('project-li').removeClassName('active');
   }
   if( $('intended-li')){
     $('intended-li').removeClassName('active');
   }
   if( $('measurable-li')){
     $('measurable-li').removeClassName('active');
   }
   if( $('photos-li')){
     $('photos-li').removeClassName('active');
   }
   if( $('videos-li')){
     $('videos-li').removeClassName('active');
   }    
   
   // deactives all, except the selected one
   item.addClassName('active');
   Element.show(section);  
 }

function init_tab(){
	if( $('project-li')){
     $('project-li').addClassName('active');
			Element.show('project_plan');  
   }
	 if( $('intended-li') && !$('project-li') ){
     $('intended-li').addClassName('active');
		 Element.show('intended_outcome'); 
   }
}
