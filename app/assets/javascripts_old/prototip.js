//  Prototip 2.1.0.1 - 19-05-2009
//  Copyright (c) 2008-2009 Nick Stakenburg (http://www.nickstakenburg.com)
//
//  Licensed under a Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 Unported License
//  http://creativecommons.org/licenses/by-nc-nd/3.0/

//  More information on this project:
//  http://www.nickstakenburg.com/projects/prototip2/

var Prototip = {
  Version: '2.1.0.1'
};

var Tips = {
  options: {
    images: '../images/prototip/', // image path, can be relative to this file or an absolute url
    zIndex: 6000                   // raise if required
  }
};

Prototip.Styles = {
  // The default style every other style will inherit from.
  // Used when no style is set through the options on a tooltip.
  'default': {
    border: 6,
    borderColor: '#c7c7c7',
    className: 'default',
    closeButton: false,
    hideAfter: false,
    hideOn: 'mouseleave',
    hook: false,
	//images: 'styles/creamy/',    // Example: different images. An absolute url or relative to the images url defined above.
    radius: 6,
	showOn: 'mousemove',
    stem: {
      //position: 'topLeft',       // Example: optional default stem position, this will also enable the stem
      height: 12,
      width: 15
    }
  },

  'protoblue': {
    className: 'protoblue',
    border: 6,
    borderColor: '#116497',
    radius: 6,
    stem: { height: 12, width: 15 }
  },

  'darkgrey': {
    className: 'darkgrey',
    border: 6,
    borderColor: '#363636',
    radius: 6,
    stem: { height: 12, width: 15 }
  },

  'creamy': {
    className: 'creamy',
    border: 6,
    borderColor: '#ebe4b4',
    radius: 6,
    stem: { height: 12, width: 15 }
  },

  'protogrey': {
    className: 'protogrey',
    border: 6,
    borderColor: '#606060',
    radius: 6,
    stem: { height: 12, width: 15 }
  }
};

Object.extend(Prototip, {
	REQUIRED_Prototype: "1.6.0.3",
	support: {
		canvas: !!document.createElement("canvas").getContext
	},
	start: function () {
		this.require("Prototype");
		if (/^(https?:\/\/|\/)/.test(Tips.options.images)) {
			Tips.images = Tips.options.images
		} else {
			var a = /prototip(?:-[\w\d.]+)?\.js(.*)/;
			Tips.images = (($$("script[src]").find(function (b) {
				return b.src.match(a)
			}) || {}).src || "").replace(a, "") + Tips.options.images
		}
		if (!this.support.canvas) {
			if (document.documentMode >= 8 && !document.namespaces.ns_vml) {
				document.namespaces.add("ns_vml", "urn:schemas-microsoft-com:vml", "#default#VML")
			} else {
				document.observe("dom:loaded", function () {
					//document.createStyleSheet().addRule("ns_vml\\:*", "behavior: url(#default#VML);")
				})
			}
		}
		Tips.initialize();
		Element.observe(window, "unload", this.unload)
	},
	require: function (a) {
		if ((typeof window[a] == "undefined") || (this.convertVersionString(window[a].Version) < this.convertVersionString(this["REQUIRED_" + a]))) {
			throw ("Prototip requires " + a + " >= " + this["REQUIRED_" + a]);
		}
	},
	convertVersionString: function (a) {
		var b = a.replace(/_.*|\./g, "");
		b = parseInt(b + "0".times(4 - b.length));
		return a.indexOf("_") > -1 ? b - 1 : b
	},
	_captureTroubleElements: $w("input textarea"),
	capture: function (a) {
		if (Prototype.Browser.IE) {
			return a
		}
		a = a.wrap(function (f, d) {
			var b = Object.isElement(this) ? this: this.element,
			c = d.relatedTarget;
			while (c && c != b) {
				try {
					c = c.parentNode
				} catch(g) {
					c = b
				}
			}
			if (c == b) {
				return
			}
			f(d)
		});
		return a
	},
	toggleInt: function (a) {
		return (a > 0) ? ( - 1 * a) : (a).abs()
	},
	unload: function () {
		Tips.removeAll()
	}
});
Object.extend(Tips, {
	tips: [],
	visible: [],
	initialize: function () {
		this.zIndexTop = this.zIndex
	},
	useEvent: (function (a) {
		return {
			mouseover: (a ? "mouseenter": "mouseover"),
			mouseout: (a ? "mouseleave": "mouseout"),
			mouseenter: (a ? "mouseenter": "mouseover"),
			mouseleave: (a ? "mouseleave": "mouseout")
		}
	})(Prototype.Browser.IE),
	specialEvent: {
		mouseover: "mouseover",
		mouseout: "mouseout",
		mouseenter: "mouseover",
		mouseleave: "mouseout"
	},
	_inverse: {
		left: "right",
		right: "left",
		top: "bottom",
		bottom: "top",
		middle: "middle",
		horizontal: "vertical",
		vertical: "horizontal"
	},
	_stemTranslation: {
		width: "horizontal",
		height: "vertical"
	},
	inverseStem: function (a) {
		return !! arguments[1] ? this._inverse[a] : a
	},
	fixIE: (function (b) {
		var a = new RegExp("MSIE ([\\d.]+)").exec(b);
		return a ? (parseFloat(a[1]) < 7) : false
	})(navigator.userAgent),
	WebKit419: (Prototype.Browser.WebKit && !document.evaluate),
	add: function (a) {
		this.tips.push(a)
	},
	remove: function (a) {
		var b = this.tips.find(function (c) {
			return c.element == $(a)
		});
		if (b) {
			b.deactivate();
			if (b.tooltip) {
				b.wrapper.remove();
				if (Tips.fixIE) {
					b.iframeShim.remove()
				}
			}
			this.tips = this.tips.without(b)
		}
		a.prototip = null
	},
	removeAll: function () {
		this.tips.each(function (a) {
			this.remove(a.element)
		}.bind(this))
	},
	raise: function (c) {
		if (c == this._highest) {
			return
		}
		if (this.visible.length === 0) {
			this.zIndexTop = this.options.zIndex;
			for (var b = 0, a = this.tips.length; b < a; b++) {
				this.tips[b].wrapper.setStyle({
					zIndex: this.options.zIndex
				})
			}
		}
		c.wrapper.setStyle({
			zIndex: this.zIndexTop++
		});
		if (c.loader) {
			c.loader.setStyle({
				zIndex: this.zIndexTop
			})
		}
		this._highest = c
	},
	addVisibile: function (a) {
		this.removeVisible(a);
		this.visible.push(a)
	},
	removeVisible: function (a) {
		this.visible = this.visible.without(a)
	},
	hideAll: function () {
		Tips.visible.invoke("hide")
	},
	hook: function (b, f) {
		b = $(b),
		f = $(f);
		var k = Object.extend({
			offset: {
				x: 0,
				y: 0
			},
			position: false
		},
		arguments[2] || {});
		var d = k.mouse || f.cumulativeOffset();
		d.left += k.offset.x;
		d.top += k.offset.y;
		var c = k.mouse ? [0, 0] : f.cumulativeScrollOffset(),
		a = document.viewport.getScrollOffsets(),
		g = k.mouse ? "mouseHook": "target";
		d.left += ( - 1 * (c[0] - a[0]));
		d.top += ( - 1 * (c[1] - a[1]));
		if (k.mouse) {
			var e = [0, 0];
			e.width = 0;
			e.height = 0
		}
		var i = {
			element: b.getDimensions()
		},
		j = {
			element: Object.clone(d)
		};
		i[g] = k.mouse ? e: f.getDimensions();
		j[g] = Object.clone(d);
		for (var h in j) {
			switch (k[h]) {
			case "topRight":
			case "rightTop":
				j[h].left += i[h].width;
				break;
			case "topMiddle":
				j[h].left += (i[h].width / 2);
				break;
			case "rightMiddle":
				j[h].left += i[h].width;
				j[h].top += (i[h].height / 2);
				break;
			case "bottomLeft":
			case "leftBottom":
				j[h].top += i[h].height;
				break;
			case "bottomRight":
			case "rightBottom":
				j[h].left += i[h].width;
				j[h].top += i[h].height;
				break;
			case "bottomMiddle":
				j[h].left += (i[h].width / 2);
				j[h].top += i[h].height;
				break;
			case "leftMiddle":
				j[h].top += (i[h].height / 2);
				break
			}
		}
		d.left += -1 * (j.element.left - j[g].left);
		d.top += -1 * (j.element.top - j[g].top);
		if (k.position) {
			b.setStyle({
				left: d.left + "px",
				top: d.top + "px"
			})
		}
		return d
	}
});
Tips.initialize();
var Tip = Class.create({
	initialize: function (c, e) {
		this.element = $(c);
		if (!this.element) {
			throw ("Prototip: Element not available, cannot create a tooltip.");
			return
		}
		Tips.remove(this.element);
		var a = (Object.isString(e) || Object.isElement(e)),
		b = a ? arguments[2] || [] : e;
		this.content = a ? e: null;
		if (b.style) {
			b = Object.extend(Object.clone(Prototip.Styles[b.style]), b)
		}
		this.options = Object.extend(Object.extend({
			ajax: false,
			border: 0,
			borderColor: "#000000",
			radius: 0,
			className: Tips.options.className,
			closeButton: Tips.options.closeButtons,
			delay: !(b.showOn && b.showOn == "click") ? 0.14 : false,
			hideAfter: false,
			hideOn: "mouseleave",
			hideOthers: false,
			hook: b.hook,
			offset: b.hook ? {
				x: 0,
				y: 0
			}: {
				x: 16,
				y: 16
			},
			fixed: (b.hook && !b.hook.mouse) ? true: false,
			showOn: "mousemove",
			stem: false,
			style: "default",
			target: this.element,
			title: false,
			viewport: (b.hook && !b.hook.mouse) ? false: true,
			width: false
		},
		Prototip.Styles["default"]), b);
		this.target = $(this.options.target);
		this.radius = this.options.radius;
		this.border = (this.radius > this.options.border) ? this.radius: this.options.border;
		if (this.options.images) {
			this.images = this.options.images.include("://") ? this.options.images: Tips.images + this.options.images
		} else {
			this.images = Tips.images + "styles/" + (this.options.style || "") + "/"
		}
		if (!this.images.endsWith("/")) {
			this.images += "/"
		}
		if (Object.isString(this.options.stem)) {
			this.options.stem = {
				position: this.options.stem
			}
		}
		if (this.options.stem.position) {
			this.options.stem = Object.extend(Object.clone(Prototip.Styles[this.options.style].stem) || {},
			this.options.stem);
			this.options.stem.position = [this.options.stem.position.match(/[a-z]+/)[0].toLowerCase(), this.options.stem.position.match(/[A-Z][a-z]+/)[0].toLowerCase()];
			this.options.stem.orientation = ["left", "right"].member(this.options.stem.position[0]) ? "horizontal": "vertical";
			this.stemInverse = {
				horizontal: false,
				vertical: false
			}
		}
		if (this.options.ajax) {
			this.options.ajax.options = Object.extend({
				onComplete: Prototype.emptyFunction
			},
			this.options.ajax.options || {})
		}
		this.useEvent = $w("area input").member(this.element.tagName.toLowerCase()) ? Tips.specialEvent: Tips.useEvent;
		if (this.options.hook.mouse) {
			var d = this.options.hook.tip.match(/[a-z]+/)[0].toLowerCase();
			this.mouseHook = Tips._inverse[d] + Tips._inverse[this.options.hook.tip.match(/[A-Z][a-z]+/)[0].toLowerCase()].capitalize()
		}
		this.fixSafari2 = (Tips.WebKit419 && this.radius);
		this.setup();
		Tips.add(this);
		this.activate();
		Prototip.extend(this)
	},
	setup: function () {
		this.wrapper = new Element("div", {
			className: "prototip"
		}).setStyle({
			zIndex: Tips.options.zIndex
		});
		if (this.fixSafari2) {
			this.wrapper.hide = function () {
				this.setStyle("left:-9500px;top:-9500px;visibility:hidden;");
				return this
			};
			this.wrapper.show = function () {
				this.setStyle("visibility:visible");
				return this
			};
			this.wrapper.visible = function () {
				return (this.getStyle("visibility") == "visible" && parseFloat(this.getStyle("top").replace("px", "")) > -9500)
			}
		}
		this.wrapper.hide();
		if (Tips.fixIE) {
			this.iframeShim = new Element("iframe", {
				className: "iframeShim",
				src: "javascript:false;",
				frameBorder: 0
			}).setStyle({
				display: "none",
				zIndex: Tips.options.zIndex - 1,
				opacity: 0
			})
		}
		if (this.options.ajax) {
			this.showDelayed = this.showDelayed.wrap(this.ajaxShow)
		}
		this.tip = new Element("div", {
			className: "content"
		});
		this.title = new Element("div", {
			className: "title"
		}).hide();
		if (this.options.closeButton || (this.options.hideOn.element && this.options.hideOn.element == "closeButton")) {
			this.closeButton = new Element("div", {
				className: "close"
			}).setPngBackground(this.images + "close.png")
		}
	},
	build: function () {
		if (document.loaded) {
			this._build();
			this._isBuilding = true;
			return true
		} else {
			if (!this._isBuilding) {
				document.observe("dom:loaded", this._build);
				return false
			}
		}
	},
	_build: function () {
		$(document.body).insert(this.wrapper);
		if (Tips.fixIE) {
			$(document.body).insert(this.iframeShim)
		}
		if (this.options.ajax) {
			$(document.body).insert(this.loader = new Element("div", {
				className: "prototipLoader"
			}).setPngBackground(this.images + "loader.gif").hide())
		}
		var g = "wrapper";
		if (this.options.stem.position) {
			this.stem = new Element("div", {
				className: "prototip_Stem"
			}).setStyle({
				height: this.options.stem[this.options.stem.orientation == "vertical" ? "height": "width"] + "px"
			});
			var b = this.options.stem.orientation == "horizontal";
			this[g].insert(this.stemWrapper = new Element("div", {
				className: "prototip_StemWrapper clearfix"
			}).insert(this.stemBox = new Element("div", {
				className: "prototip_StemBox clearfix"
			})));
			this.stem.insert(this.stemImage = new Element("div", {
				className: "prototip_StemImage"
			}).setStyle({
				height: this.options.stem[b ? "width": "height"] + "px",
				width: this.options.stem[b ? "height": "width"] + "px"
			}));
			if (Tips.fixIE && !this.options.stem.position[1].toUpperCase().include("MIDDLE")) {
				this.stemImage.setStyle({
					display: "inline"
				})
			}
			g = "stemBox"
		}
		if (this.border) {
			var d = this.border,
			f;
			this[g].insert(this.borderFrame = new Element("ul", {
				className: "borderFrame"
			}).insert(this.borderTop = new Element("li", {
				className: "borderTop borderRow"
			}).setStyle("height: " + d + "px").insert(new Element("div", {
				className: "prototip_CornerWrapper prototip_CornerWrapperTopLeft"
			}).insert(new Element("div", {
				className: "prototip_Corner"
			}))).insert(f = new Element("div", {
				className: "prototip_BetweenCorners"
			}).setStyle({
				height: d + "px"
			}).insert(new Element("div", {
				className: "prototip_Between"
			}).setStyle({
				margin: "0 " + d + "px",
				height: d + "px"
			}))).insert(new Element("div", {
				className: "prototip_CornerWrapper prototip_CornerWrapperTopRight"
			}).insert(new Element("div", {
				className: "prototip_Corner"
			})))).insert(this.borderMiddle = new Element("li", {
				className: "borderMiddle borderRow"
			}).insert(this.borderCenter = new Element("div", {
				className: "borderCenter"
			}).setStyle("padding: 0 " + d + "px"))).insert(this.borderBottom = new Element("li", {
				className: "borderBottom borderRow"
			}).setStyle("height: " + d + "px").insert(new Element("div", {
				className: "prototip_CornerWrapper prototip_CornerWrapperBottomLeft"
			}).insert(new Element("div", {
				className: "prototip_Corner"
			}))).insert(f.cloneNode(true)).insert(new Element("div", {
				className: "prototip_CornerWrapper prototip_CornerWrapperBottomRight"
			}).insert(new Element("div", {
				className: "prototip_Corner"
			})))));
			g = "borderCenter";
			var c = this.borderFrame.select(".prototip_Corner");
			$w("tl tr bl br").each(function (j, h) {
				if (this.radius > 0) {
					Prototip.createCorner(c[h], j, {
						backgroundColor: this.options.borderColor,
						border: d,
						radius: this.options.radius
					})
				} else {
					c[h].addClassName("prototip_Fill")
				}
				c[h].setStyle({
					width: d + "px",
					height: d + "px"
				}).addClassName("prototip_Corner" + j.capitalize())
			}.bind(this));
			this.borderFrame.select(".prototip_Between", ".borderMiddle", ".prototip_Fill").invoke("setStyle", {
				backgroundColor: this.options.borderColor
			})
		}
		this[g].insert(this.tooltip = new Element("div", {
			className: "tooltip " + this.options.className
		}).insert(this.toolbar = new Element("div", {
			className: "toolbar"
		}).insert(this.title)));
		if (this.options.width) {
			var e = this.options.width;
			if (Object.isNumber(e)) {
				e += "px"
			}
			this.tooltip.setStyle("width:" + e)
		}
		if (this.stem) {
			var a = {};
			a[this.options.stem.orientation == "horizontal" ? "top": "bottom"] = this.stem;
			this.wrapper.insert(a);
			this.positionStem()
		}
		this.tooltip.insert(this.tip);
		if (!this.options.ajax) {
			this._update({
				title: this.options.title,
				content: this.content
			})
		}
	},
	_update: function (e) {
		var a = this.wrapper.getStyle("visibility");
		this.wrapper.setStyle("height:auto;width:auto;visibility:hidden").show();
		if (this.border) {
			this.borderTop.setStyle("height:0");
			this.borderTop.setStyle("height:0")
		}
		if (e.title) {
			this.title.show().update(e.title);
			this.toolbar.show()
		} else {
			if (!this.closeButton) {
				this.title.hide();
				this.toolbar.hide()
			}
		}
		if (Object.isElement(e.content)) {
			e.content.show()
		}
		if (Object.isString(e.content) || Object.isElement(e.content)) {
			this.tip.update(e.content)
		}
		this.tooltip.setStyle({
			width: this.tooltip.getWidth() + "px"
		});
		this.wrapper.setStyle("visibility:visible").show();
		this.tooltip.show();
		var c = this.tooltip.getDimensions(),
		b = {
			width: c.width + "px"
		},
		d = [this.wrapper];
		if (Tips.fixIE) {
			d.push(this.iframeShim)
		}
		if (this.closeButton) {
			this.title.show().insert({
				top: this.closeButton
			});
			this.toolbar.show()
		}
		if (e.title || this.closeButton) {
			this.toolbar.setStyle("width: 100%")
		}
		b.height = null;
		this.wrapper.setStyle({
			visibility: a
		});
		this.tip.addClassName("clearfix");
		if (e.title || this.closeButton) {
			this.title.addClassName("clearfix")
		}
		if (this.border) {
			this.borderTop.setStyle("height:" + this.border + "px");
			this.borderTop.setStyle("height:" + this.border + "px");
			b = "width: " + (c.width + 2 * this.border) + "px";
			d.push(this.borderFrame)
		}
		d.invoke("setStyle", b);
		if (this.stem) {
			this.positionStem();
			if (this.options.stem.orientation == "horizontal") {
				this.wrapper.setStyle({
					width: this.wrapper.getWidth() + this.options.stem.height + "px"
				})
			}
		}
		this.wrapper.hide()
	},
	activate: function () {
		this.eventShow = this.showDelayed.bindAsEventListener(this);
		this.eventHide = this.hide.bindAsEventListener(this);
		if (this.options.fixed && this.options.showOn == "mousemove") {
			this.options.showOn = "mouseover"
		}
		if (this.options.showOn == this.options.hideOn) {
			this.eventToggle = this.toggle.bindAsEventListener(this);
			this.element.observe(this.options.showOn, this.eventToggle)
		}
		if (this.closeButton) {
			this.closeButton.observe("mouseover", function (e) {
				e.setPngBackground(this.images + "close_hover.png")
			}.bind(this, this.closeButton)).observe("mouseout", function (e) {
				e.setPngBackground(this.images + "close.png")
			}.bind(this, this.closeButton))
		}
		var c = {
			element: this.eventToggle ? [] : [this.element],
			target: this.eventToggle ? [] : [this.target],
			tip: this.eventToggle ? [] : [this.wrapper],
			closeButton: [],
			none: []
		},
		a = this.options.hideOn.element;
		this.hideElement = a || (!this.options.hideOn ? "none": "element");
		this.hideTargets = c[this.hideElement];
		if (!this.hideTargets && a && Object.isString(a)) {
			this.hideTargets = this.tip.select(a)
		}
		var d = {
			mouseenter: "mouseover",
			mouseleave: "mouseout"
		};
		$w("show hide").each(function (h) {
			var g = h.capitalize(),
			f = (this.options[h + "On"].event || this.options[h + "On"]);
			this[h + "Action"] = f;
			if (["mouseenter", "mouseleave", "mouseover", "mouseout"].include(f)) {
				this[h + "Action"] = (this.useEvent[f] || f);
				this["event" + g] = Prototip.capture(this["event" + g])
			}
		}.bind(this));
		if (!this.eventToggle) {
			this.element.observe(this.options.showOn, this.eventShow)
		}
		if (this.hideTargets) {
			this.hideTargets.invoke("observe", this.hideAction, this.eventHide)
		}
		if (!this.options.fixed && this.options.showOn == "click") {
			this.eventPosition = this.position.bindAsEventListener(this);
			this.element.observe("mousemove", this.eventPosition)
		}
		this.buttonEvent = this.hide.wrap(function (g, f) {
			var e = f.findElement(".close");
			if (e) {
				e.blur();
				f.stop();
				g(f)
			}
		}).bindAsEventListener(this);
		if (this.closeButton || (this.options.hideOn && (this.options.hideOn.element == ".close"))) {
			this.wrapper.observe("click", this.buttonEvent)
		}
		if (this.options.showOn != "click" && (this.hideElement != "element")) {
			this.eventCheckDelay = Prototip.capture(function () {
				this.clearTimer("show")
			}).bindAsEventListener(this);
			this.element.observe(this.useEvent.mouseout, this.eventCheckDelay)
		}
		var b = [this.element, this.wrapper];
		this.activityEnter = Prototip.capture(function () {
			Tips.raise(this);
			this.cancelHideAfter()
		}).bindAsEventListener(this);
		this.activityLeave = Prototip.capture(this.hideAfter).bindAsEventListener(this);
		b.invoke("observe", this.useEvent.mouseover, this.activityEnter).invoke("observe", this.useEvent.mouseout, this.activityLeave);
		if (this.options.ajax && this.options.showOn != "click") {
			this.ajaxHideEvent = Prototip.capture(this.ajaxHide).bindAsEventListener(this);
			this.element.observe(this.useEvent.mouseout, this.ajaxHideEvent)
		}
	},
	deactivate: function () {
		if (this.options.showOn == this.options.hideOn) {
			this.element.stopObserving(this.options.showOn, this.eventToggle)
		} else {
			this.element.stopObserving(this.options.showOn, this.eventShow);
			if (this.hideTargets) {
				this.hideTargets.invoke("stopObserving")
			}
		}
		if (this.eventPosition) {
			this.element.stopObserving("mousemove", this.eventPosition)
		}
		if (this.eventCheckDelay) {
			this.element.stopObserving("mouseout", this.eventCheckDelay)
		}
		this.wrapper.stopObserving();
		this.element.stopObserving(this.useEvent.mouseover, this.activityEnter).stopObserving(this.useEvent.mouseout, this.activityLeave);
		if (this.ajaxHideEvent) {
			this.element.stopObserving(this.useEvent.mouseout, this.ajaxHideEvent)
		}
	},
	ajaxShow: function (c, b) {
		if (!this.tooltip) {
			if (!this.build()) {
				return
			}
		}
		this.position(b);
		if (this.ajaxContentLoading) {
			return
		} else {
			if (this.ajaxContentLoaded) {
				c(b);
				return
			}
		}
		this.ajaxContentLoading = true;
		var e = b.pointer(),
		d = {
			fakePointer: {
				pointerX: e.x,
				pointerY: e.y
			}
		};
		var a = Object.clone(this.options.ajax.options);
		a.onComplete = a.onComplete.wrap(function (g, f) {
			this._update({
				title: this.options.title,
				content: f.responseText
			});
			this.position(d);
			(function () {
				g(f);
				var h = (this.loader && this.loader.visible());
				if (this.loader) {
					this.clearTimer("loader");
					this.loader.remove();
					this.loader = null
				}
				if (h) {
					this.show()
				}
				this.ajaxContentLoaded = true;
				this.ajaxContentLoading = null
			}.bind(this)).delay(0.6)
		}.bind(this));
		this.loaderTimer = Element.show.delay(this.options.delay, this.loader);
		this.wrapper.hide();
		this.ajaxContentLoading = true;
		this.loader.show();
		this.ajaxTimer = (function () {
			new Ajax.Request(this.options.ajax.url, a)
		}.bind(this)).delay(this.options.delay);
		return false
	},
	ajaxHide: function () {
		this.clearTimer("loader")
	},
	showDelayed: function (a) {
		if (!this.tooltip) {
			if (!this.build()) {
				return
			}
		}
		this.position(a);
		if (this.wrapper.visible()) {
			return
		}
		this.clearTimer("show");
		this.showTimer = this.show.bind(this).delay(this.options.delay)
	},
	clearTimer: function (a) {
		if (this[a + "Timer"]) {
			clearTimeout(this[a + "Timer"])
		}
	},
	show: function () {
		if (this.wrapper.visible()) {
			return
		}
		if (Tips.fixIE) {
			this.iframeShim.show()
		}
		if (this.options.hideOthers) {
			Tips.hideAll()
		}
		Tips.addVisibile(this);
		this.tooltip.show();
		this.wrapper.show();
		if (this.stem) {
			this.stem.show()
		}
		this.element.fire("prototip:shown")
	},
	hideAfter: function (a) {
		if (this.options.ajax) {
			if (this.loader && this.options.showOn != "click") {
				this.loader.hide()
			}
		}
		if (!this.options.hideAfter) {
			return
		}
		this.cancelHideAfter();
		this.hideAfterTimer = this.hide.bind(this).delay(this.options.hideAfter)
	},
	cancelHideAfter: function () {
		if (this.options.hideAfter) {
			this.clearTimer("hideAfter")
		}
	},
	hide: function () {
		this.clearTimer("show");
		this.clearTimer("loader");
		if (!this.wrapper.visible()) {
			return
		}
		this.afterHide()
	},
	afterHide: function () {
		if (Tips.fixIE) {
			this.iframeShim.hide()
		}
		if (this.loader) {
			this.loader.hide()
		}
		this.wrapper.hide();
		(this.borderFrame || this.tooltip).show();
		Tips.removeVisible(this);
		this.element.fire("prototip:hidden")
	},
	toggle: function (a) {
		if (this.wrapper && this.wrapper.visible()) {
			this.hide(a)
		} else {
			this.showDelayed(a)
		}
	},
	positionStem: function () {
		var c = this.options.stem,
		b = arguments[0] || this.stemInverse,
		d = Tips.inverseStem(c.position[0], b[c.orientation]),
		f = Tips.inverseStem(c.position[1], b[Tips._inverse[c.orientation]]),
		a = this.radius || 0;
		this.stemImage.setPngBackground(this.images + d + f + ".png");
		if (c.orientation == "horizontal") {
			var e = (d == "left") ? c.height: 0;
			this.stemWrapper.setStyle("left: " + e + "px;");
			this.stemImage.setStyle({
				"float": d
			});
			this.stem.setStyle({
				left: 0,
				top: (f == "bottom" ? "100%": f == "middle" ? "50%": 0),
				marginTop: (f == "bottom" ? -1 * c.width: f == "middle" ? -0.5 * c.width: 0) + (f == "bottom" ? -1 * a: f == "top" ? a: 0) + "px"
			})
		} else {
			this.stemWrapper.setStyle(d == "top" ? "margin: 0; padding: " + c.height + "px 0 0 0;": "padding: 0; margin: 0 0 " + c.height + "px 0;");
			this.stem.setStyle(d == "top" ? "top: 0; bottom: auto;": "top: auto; bottom: 0;");
			this.stemImage.setStyle({
				margin: 0,
				"float": f != "middle" ? f: "none"
			});
			if (f == "middle") {
				this.stemImage.setStyle("margin: 0 auto;")
			} else {
				this.stemImage.setStyle("margin-" + f + ": " + a + "px;")
			}
			if (Tips.WebKit419) {
				if (d == "bottom") {
					this.stem.setStyle({
						position: "relative",
						clear: "both",
						top: "auto",
						bottom: "auto",
						"float": "left",
						width: "100%",
						margin: ( - 1 * c.height) + "px 0 0 0"
					});
					this.stem.style.display = "block"
				} else {
					this.stem.setStyle({
						position: "absolute",
						"float": "none",
						margin: 0
					})
				}
			}
		}
		this.stemInverse = b
	},
	position: function (b) {
		if (!this.tooltip) {
			if (!this.build()) {
				return
			}
		}
		Tips.raise(this);
		if (Tips.fixIE) {
			var a = this.wrapper.getDimensions();
			if (!this.iframeShimDimensions || this.iframeShimDimensions.height != a.height || this.iframeShimDimensions.width != a.width) {
				this.iframeShim.setStyle({
					width: a.width + "px",
					height: a.height + "px"
				})
			}
			this.iframeShimDimensions = a
		}
		if (this.options.hook) {
			var j, h;
			if (this.mouseHook) {
				var k = document.viewport.getScrollOffsets(),
				c = b.fakePointer || {};
				var g, i = 2;
				switch (this.mouseHook.toUpperCase()) {
				case "LEFTTOP":
				case "TOPLEFT":
					g = {
						x: 0 - i,
						y: 0 - i
					};
					break;
				case "TOPMIDDLE":
					g = {
						x: 0,
						y: 0 - i
					};
					break;
				case "TOPRIGHT":
				case "RIGHTTOP":
					g = {
						x: i,
						y: 0 - i
					};
					break;
				case "RIGHTMIDDLE":
					g = {
						x: i,
						y: 0
					};
					break;
				case "RIGHTBOTTOM":
				case "BOTTOMRIGHT":
					g = {
						x: i,
						y: i
					};
					break;
				case "BOTTOMMIDDLE":
					g = {
						x: 0,
						y: i
					};
					break;
				case "BOTTOMLEFT":
				case "LEFTBOTTOM":
					g = {
						x: 0 - i,
						y: i
					};
					break;
				case "LEFTMIDDLE":
					g = {
						x: 0 - i,
						y: 0
					};
					break
				}
				g.x += this.options.offset.x;
				g.y += this.options.offset.y;
				j = Object.extend({
					offset: g
				},
				{
					element: this.options.hook.tip,
					mouseHook: this.mouseHook,
					mouse: {
						top: c.pointerY || Event.pointerY(b) - k.top,
						left: c.pointerX || Event.pointerX(b) - k.left
					}
				});
				h = Tips.hook(this.wrapper, this.target, j);
				if (this.options.viewport) {
					var n = this.getPositionWithinViewport(h),
					m = n.stemInverse;
					h = n.position;
					h.left += m.vertical ? 2 * Prototip.toggleInt(g.x - this.options.offset.x) : 0;
					h.top += m.vertical ? 2 * Prototip.toggleInt(g.y - this.options.offset.y) : 0;
					if (this.stem && (this.stemInverse.horizontal != m.horizontal || this.stemInverse.vertical != m.vertical)) {
						this.positionStem(m)
					}
				}
				h = {
					left: h.left + "px",
					top: h.top + "px"
				};
				this.wrapper.setStyle(h)
			} else {
				j = Object.extend({
					offset: this.options.offset
				},
				{
					element: this.options.hook.tip,
					target: this.options.hook.target
				});
				h = Tips.hook(this.wrapper, this.target, Object.extend({
					position: true
				},
				j));
				h = {
					left: h.left + "px",
					top: h.top + "px"
				}
			}
			if (this.loader) {
				var e = Tips.hook(this.loader, this.target, Object.extend({
					position: true
				},
				j))
			}
			if (Tips.fixIE) {
				this.iframeShim.setStyle(h)
			}
		} else {
			var f = this.target.cumulativeOffset(),
			c = b.fakePointer || {},
			h = {
				left: ((this.options.fixed) ? f[0] : c.pointerX || Event.pointerX(b)) + this.options.offset.x,
				top: ((this.options.fixed) ? f[1] : c.pointerY || Event.pointerY(b)) + this.options.offset.y
			};
			if (!this.options.fixed && this.element !== this.target) {
				var d = this.element.cumulativeOffset();
				h.left += -1 * (d[0] - f[0]);
				h.top += -1 * (d[1] - f[1])
			}
			if (!this.options.fixed && this.options.viewport) {
				var n = this.getPositionWithinViewport(h),
				m = n.stemInverse;
				h = n.position;
				if (this.stem && (this.stemInverse.horizontal != m.horizontal || this.stemInverse.vertical != m.vertical)) {
					this.positionStem(m)
				}
			}
			h = {
				left: h.left + "px",
				top: h.top + "px"
			};
			this.wrapper.setStyle(h);
			if (this.loader) {
				this.loader.setStyle(h)
			}
			if (Tips.fixIE) {
				this.iframeShim.setStyle(h)
			}
		}
	},
	getPositionWithinViewport: function (c) {
		var e = {
			horizontal: false,
			vertical: false
		},
		d = this.wrapper.getDimensions(),
		b = document.viewport.getScrollOffsets(),
		a = document.viewport.getDimensions(),
		g = {
			left: "width",
			top: "height"
		};
		for (var f in g) {
			if ((c[f] + d[g[f]] - b[f]) > a[g[f]]) {
				c[f] = c[f] - (d[g[f]] + (2 * this.options.offset[f == "left" ? "x": "y"]));
				if (this.stem) {
					e[Tips._stemTranslation[g[f]]] = true
				}
			}
		}
		return {
			position: c,
			stemInverse: e
		}
	}
});
Object.extend(Prototip, {
	createCorner: function (d, g) {
		var j = arguments[2] || this.options,
		f = j.radius,
		c = j.border,
		e = {
			top: (g.charAt(0) == "t"),
			left: (g.charAt(1) == "l")
		};
		if (this.support.canvas) {
			var b = new Element("canvas", {
				className: "cornerCanvas" + g.capitalize(),
				width: c + "px",
				height: c + "px"
			});
			d.insert(b);
			var i = b.getContext("2d");
			i.fillStyle = j.backgroundColor;
			i.arc((e.left ? f: c - f), (e.top ? f: c - f), f, 0, Math.PI * 2, true);
			i.fill();
			i.fillRect((e.left ? f: 0), 0, c - f, c);
			i.fillRect(0, (e.top ? f: 0), c, c - f)
		} else {
			var h;
			d.insert(h = new Element("div").setStyle({
				width: c + "px",
				height: c + "px",
				margin: 0,
				padding: 0,
				display: "block",
				position: "relative",
				overflow: "hidden"
			}));
			var a = new Element("ns_vml:roundrect", {
				fillcolor: j.backgroundColor,
				strokeWeight: "1px",
				strokeColor: j.backgroundColor,
				arcSize: (f / c * 0.5).toFixed(2)
			}).setStyle({
				width: 2 * c - 1 + "px",
				height: 2 * c - 1 + "px",
				position: "absolute",
				left: (e.left ? 0 : ( - 1 * c)) + "px",
				top: (e.top ? 0 : ( - 1 * c)) + "px"
			});
			h.insert(a);
			a.outerHTML = a.outerHTML
		}
	}
});
Element.addMethods({
	setPngBackground: function (c, b) {
		c = $(c);
		var a = Object.extend({
			align: "top left",
			repeat: "no-repeat",
			sizingMethod: "scale",
			backgroundColor: ""
		},
		arguments[2] || {});
		c.setStyle(Tips.fixIE ? {
			filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + b + "'', sizingMethod='" + a.sizingMethod + "')"
		}: {
			background: a.backgroundColor + " url(" + b + ") " + a.align + " " + a.repeat
		});
		return c
	}
});
Prototip.Methods = {
	show: function () {
		Tips.raise(this);
		this.cancelHideAfter();
		var d = {};
		if (this.options.hook) {
			d.fakePointer = {
				pointerX: 0,
				pointerY: 0
			}
		} else {
			var a = this.target.cumulativeOffset(),
			c = this.target.cumulativeScrollOffset(),
			b = document.viewport.getScrollOffsets();
			a.left += ( - 1 * (c[0] - b[0]));
			a.top += ( - 1 * (c[1] - b[1]));
			d.fakePointer = {
				pointerX: a.left,
				pointerY: a.top
			}
		}
		if (this.options.ajax) {
			this.ajaxShow(d)
		} else {
			this.showDelayed(d)
		}
		this.hideAfter()
	}
};
Prototip.extend = function (a) {
	a.element.prototip = {};
	Object.extend(a.element.prototip, {
		show: Prototip.Methods.show.bind(a),
		hide: a.hide.bind(a),
		remove: Tips.remove.bind(Tips, a.element)
	})
};
Prototip.start();