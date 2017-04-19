$(document).ready(() => {
	uname = [];
	stack = [];
	url = window.location.href;
	for(i=url.length-1; i>0; i--) {
		if(url[i] === '/') {
			break;
		}
		stack.push(url[i])
	}

	while(stack.length != 0) {
		uname.push(stack.pop());
	}

	uname = uname.join('');
	console.log(name);

	$.ajax({
		url: '/request',
		type: 'POST',
		dataType: 'json',
		contentType: 'application/x-www-form-urlencoded',
		data: {
			action: 'get_detailed_view_user',
			username: uname
		},
		success: (res) => {
			$('#user-wrapper').html(res.html);
		},
		error: () => {
			alert('Something went wrong, try again later...');
		}
	});
});
