

(function(){
	var topButton = document.getElementById("back-to-top");

	topButton.addEventListener("click",function(e){
		e.preventDefault();
		window.scrollTo(0, 0);
	});
})();
