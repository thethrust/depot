
// Name:         Jumper.js
// Purpose:      Scroll to a target from a link 
// Dependencies: jQuery, Love 
// Developer:    Troy Griggs 

;(function($, undefined){

	var pluginName = 'jumper',
	defaults = {
		targetClass: '.j-target',
		targetType: 'div',
		padding: 0,
		transition: 400
	};

	function Plugin(element, options){
		this.element = element;
		this.opts = $.extend(defaults, options);
		this._defaults = defaults;
		this._name = pluginName; 
		this.init();
	};
	
	Plugin.prototype.init = function(){
		var self = this;
		this.setClick();
	};

	Plugin.prototype.setClick = function(){
		var self = this,
			$link = $(this.element),
			$target = $( this.opts.targetType + '[data-target="'+ $link.data("link") +'"]').first();

		$link.on("click",function(e){
			e.preventDefault();
			self.scrollOnClick( $(this), $target );
		});
	};

	Plugin.prototype.scrollOnClick = function(link, target){
		var targetTop = target.offset().top;
		$('html, body').animate({ scrollTop: targetTop - this.opts.padding }, this.opts.transition);
	};

	$.fn[pluginName] = function (options) {
		return this.each(function(){
			if (!$.data(this, 'plugin_' + pluginName)) {
				$.data(this, 'plugin_' + pluginName, new Plugin( this, options ));
			}
		});
	};

})(jQuery);


// IMPLEMENTATION 
// $(".j-link").jumper({});