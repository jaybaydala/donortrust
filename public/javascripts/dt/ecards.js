Event.observe(window, 'load', function() {
	if (ecard_links = $$("#miniThumbs a")) {
		new Ecards(ecard_links)
	}
	if (ecard_preview = $('ecardPreview')) {
		ecard_preview.show();
	}
});

var Ecards = Class.create();
Ecards.prototype = {
	cards: null,
	medium_container: 'mediumEcard',
	form_container: 'ecardsrc',
	current: null,
	initialize: function(card_links, medium_container, form_container) {
		// set up the containerz
		if (medium_container) this.medium_container = medium_container
		if (form_container) this.form_container = form_container
		// load the cards
		this.cards = new Array;
		i = 0;
		for (i=0;i<card_links.length;i++) {
			this.cards[i] = new Ecard(card_links[i]);
			// when a small image gets clicked, put it in the medium "preview" area
			Event.observe(card_links[i], 'click', this.preview.bindAsEventListener(this, i));
		}
		// set the first card as current
		this.preview(null, 0)
		/*
		if (this.current = $(this.medium_container)) {
			// when a medium image gets clicked, load it into the large image container
			Event.observe(current, 'click', this.choose.bindAsEventListener(this));
			Event.observe($('ecardSelect'), 'click', this.choose.bindAsEventListener(this));
		}
		*/
	},
	preview: function(e, card_index) {
		if (img = $(this.medium_container)) {
			img.src = this.cards[card_index].medium
			if (form_el = $(this.form_container)) {
				form_el.value = this.cards[card_index].large
			}
			this.current = card_index
		}
	}
	/*,
	choose: function(e) {
		if (img = $(this.large_container)) {
			img.src = $(this.medium_container).src.replace(/\/medium\//, '/large/');
		}
	}
	*/
}

var Ecard = Class.create();
Ecard.prototype = {
	small: null,
	medium: null,
	large: null,
	initialize: function(link, medium_container, large_container) {
		if (link.getAttribute("href")) {
			link.target = ""
			// set up the sizes
			if (link.getAttribute("href").match(/\/medium\//)) {
				this.medium = link.getAttribute("href")
				this.small = link.getAttribute("href").replace(/\/medium\//, '/small/');
				this.large = link.getAttribute("href").replace(/\/medium\//, '/large/');
				link.href = "javascript:void(0);"
			}
		}
	}
}