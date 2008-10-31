Event.observe(window, 'load', function() {
	if (typeof(ecards) != 'undefined') {
		new Ecards(ecards)
	}
	if (ecard_preview = $('ecardPreview')) {
		ecard_preview.show();
	}
});

var Ecards = Class.create();
Ecards.prototype = {
	cards: null,
	medium_container: 'mediumEcard',
	preview_container: 'previewEcard',
	form_container: 'e_card_id',
	current: null,
	initialize: function(ecards, medium_container, form_container, preview_container) {
		// set up the containerz
		if (medium_container) this.medium_container = medium_container
		if (form_container) this.form_container = form_container
		if (preview_container) this.preview_container = preview_container
		// load the cards
		this.cards = new Hash();
		i = 0;
		ecards.each(function(pair) {
			key = pair.key
			value = pair.value
			this.cards.set(key, new Ecard(value.id, value.small, value.medium, value.large))
			ecard_link = $("ecard-link-"+value.id);
			Event.observe(ecard_link, 'click', this.select.bindAsEventListener(this, value.id));
		}, this);
		// set the card
		this.change($F('e_card_id'))
	},
	select: function(e, card_id) {
		this.change(card_id);
	},
	change: function(card_id) {
		if (img = $(this.medium_container)) {
			card = this.cards.get(card_id)
			img.src = card.medium
			if (form_el = $(this.form_container)) {
				form_el.value = card.id
			}
			if (preview_el = $(this.preview_container)) {
				preview_el.src = card.small
			}
			this.current = card_id
		}
	}
}

var Ecard = Class.create();
Ecard.prototype = {
	id: null,
	small: null,
	medium: null,
	large: null,
	initialize: function(id, small, medium, large) {
		this.id = id
		this.small = small
		this.medium = medium
		this.large = large
		ecard_link = $("ecard-link-"+id);
		if (ecard_link.getAttribute("href")) {
			ecard_link.target = ""
			ecard_link.rel = ""
			ua=navigator.userAgent.toLowerCase();
			ie = document.all && ua.search(/msie/i) != -1 ? true : false;
			old_ie = ie && ua.search(/msie [0-6]/i) != -1 ? true : false;
			ecard_link.href = old_ie ? "#previewEcard" : 'javascript:void(0);'
		}
	}
}