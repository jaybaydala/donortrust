Event.observe(window, 'load', function() {
	if (ecard_links = $$("#miniThumbs a")) {
		ecard_links.each(function(link) {
			new Ecard(link);
		});
	}
});

var Ecard = Class.create();
Ecard.prototype = {
	small: null,
	medium: null,
	large: null,
	medium_container: 'mediumEcard',
	large_container: 'largeEcard',
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
			// set up the containerz
			if (medium_container) this.medium_container = medium_container
			if (large_container) this.large_container = large_container
			// when a small image gets clicked, put it in the medium "preview" area
			Event.observe(link, 'click', this.zoom_small.bindAsEventListener(this));
			if (current = $(this.medium_container)) {
				// when a medium image gets clicked, load it into the large image container
				Event.observe(current, 'click', this.choose.bindAsEventListener(this));
				Event.observe($('ecardSelect'), 'click', this.choose.bindAsEventListener(this));
			}
		}
	},
	zoom_small: function(e) {
		if (img = $(this.medium_container)) {
			img.src = this.medium
		}
	},
	choose: function(e) {
		if (img = $(this.large_container)) {
			img.src = $(this.medium_container).src.replace(/\/medium\//, '/large/');
		}
	}
}