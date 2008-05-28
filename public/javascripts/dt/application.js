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
			new Effect.Highlight(s,{delay:2,duration:1,startcolor:'#FFFFEE',endcolor:'#FFFFFF',restorecolor:'#FFFFFF'})
		});
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
