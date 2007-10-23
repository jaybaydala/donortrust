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
		this.cards = new Array;
		i = 0;
		for (i=0;i<ecards.length;i++) {
			this.cards[i] = new Ecard(ecards[i].id, ecards[i].small, ecards[i].medium, ecards[i].large);
			// when a small image gets clicked, put it in the medium "preview" area
			ecard_link = $("ecard-link-"+ecards[i].id);
			Event.observe(ecard_link, 'click', this.select.bindAsEventListener(this, i));
		}
		// set the first card as current
		this.select(null, 0)
	},
	select: function(e, card_index) {
		if (img = $(this.medium_container)) {
			img.src = this.cards[card_index].medium
			if (form_el = $(this.form_container)) {
				form_el.value = this.cards[card_index].id
			}
			if (preview_el = $(this.preview_container)) {
				preview_el.src = this.cards[card_index].small
			}
			this.current = card_index
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
			ecard_link.href = "javascript:void(0);"
		}
	}
}