
window.addEventListener("load", () => {
	let displayLink = link => {
		alert(link);
	}

	document.querySelectorAll('tr.id').forEach(e => {
		e.addEventListener('click', e => {
			let id  = e.target.parentElement.getAttribute('id');
			displayLink(window.location.origin + "/posts/?id="+id);
			window.location = window.location.origin + "/posts/?id="+id;			
		})
	})
})
