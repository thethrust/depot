(function(){

	function init(){
		setBackToTop();
	};

	// Back to top button 
	function setBackToTop(){
		var topButton = document.getElementById("back-to-top");

		topButton.addEventListener("click",function(e){
			e.preventDefault();
			// window.scrollTo(0, 0);
			scrollTo(document.body, 0, 200);
		});

		function scrollTo(element, to, duration) {
			if (duration <= 0) return;
			var difference = to - element.scrollTop;
			var perTick = difference / duration * 10;

			setTimeout(function() {
				element.scrollTop = element.scrollTop + perTick;
				if (element.scrollTop == to) return;
				scrollTo(element, to, duration - 10);
			}, 10);
		}
	};

	init();

})();
