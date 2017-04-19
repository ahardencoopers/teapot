$(document).ready(() => {
	urlid = [];
	stack = [];
	url = window.location.href;
	for(i=url.length-1; i>0; i--) {
		if(url[i] === '/') {
			break;
		}
		stack.push(url[i])
	}

	while(stack.length != 0) {
		urlid.push(stack.pop());
	}

	id = urlid.join('');
	
	$.ajax({
		url: '/request',
		type: 'POST',
		dataType: 'json',
		contentType: 'application/x-www-form-urlencoded',
		data: {
			action: 'get_detailed_view',
			urlid: id
		},
		success: (res) => {
			$('#video-wrapper').html(res.html);
		},
		error: () => {
			alert('Something went wrong, try again later...');
		}
	});
});
